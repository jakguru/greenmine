class GitlabProject < ActiveRecord::Base
  include Redmine::SafeAttributes
  # Associations
  belongs_to :gitlab_instance, class_name: "GitlabInstance", foreign_key: "gitlab_id"
  has_many :project_gitlab_projects, class_name: "ProjectGitlabProject", foreign_key: "gitlab_project_id"
  has_many :projects, through: :project_gitlab_projects
  # Association with RemoteGit Models
  has_many :branches, as: :branchable, class_name: "RemoteGit::Branch", dependent: :destroy
  has_many :commits, as: :commitable, class_name: "RemoteGit::Commit", dependent: :destroy
  has_many :merge_requests, as: :merge_requestable, class_name: "RemoteGit::MergeRequest", dependent: :destroy
  has_many :tags, as: :taggable, class_name: "RemoteGit::Tag", dependent: :destroy
  has_many :releases, through: :tags, class_name: "RemoteGit::Release"
  has_many :pipelines, through: :branches, class_name: "RemoteGit::Pipeline"
  has_many :pipelines, through: :tags, class_name: "RemoteGit::Pipeline"
  has_many :pipelines, through: :commits, class_name: "RemoteGit::Pipeline"

  # Validations
  validates :gitlab_id, presence: true
  validates :project_id, presence: true  # This represents the GitLab API project ID
  validates :name, presence: true
  validates :name_with_namespace, presence: true
  validates :path, presence: true
  validates :path_with_namespace, presence: true

  def safe_attribute?(attribute)
    # You can add more complex logic here based on attribute security, but for now, return true for all attributes
    true
  end

  def projects=(projects)
    set_associated_projects(projects)
  end

  def set_associated_projects(projects)
    existing_projects = self.projects
    # Remove any projects that are no longer associated
    existing_projects.each do |project|
      if !projects.any? { |p| p.id == project.id }
        project_gitlab_project = ProjectGitlabProject.where(project_id: project.id, gitlab_project_id: self[:id]).first
        project_gitlab_project.destroy
      end
    end
    # Add any new projects
    projects.each do |project|
      if !existing_projects.any? { |p| p.id == project.id }
        project_gitlab_project = ProjectGitlabProject.new(project_id: project.id, gitlab_project_id: self[:id])
        project_gitlab_project.save
      end
    end
    ActionCable.server.broadcast("rtu_project_gitlab_project", {gitlab_instance_id: gitlab_instance.id, gitlab_project_id: self[:id]})
  end

  def web_url
    "#{gitlab_instance.url}/#{path_with_namespace}"
  end

  def git_http_url
    "#{gitlab_instance.url}/#{path_with_namespace}.git"
  end

  def git_ssh_url
    "git@#{gitlab_instance.url.sub("https://", "")}:#{path_with_namespace}.git"
  end

  def remote_info
    client = gitlab_instance.api_client
    client.project(self[:project_id])
  end

  def do_process_webhook(params, headers)
    # Normalize header keys to lowercase strings for consistent access
    headers = headers.transform_keys { |key| key.to_s.downcase }

    event_type = headers["x-gitlab-event"]

    if event_type.blank?
      Rails.logger.error("Missing X-GitLab-Event header. Unable to process webhook.")
      return
    end

    Rails.logger.info("Received GitLab webhook for project #{name}: event=#{event_type}")

    # Route the event to a specific handler method
    case event_type
    when "Push Hook"
      handle_push_event(params)
    when "Tag Push Hook"
      handle_tag_push_event(params)
    when "Merge Request Hook"
      handle_merge_request_event(params)
    when "Pipeline Hook"
      handle_pipeline_event(params)
    when "Job Hook"
      handle_job_event(params)
    when "Release Hook"
      handle_release_event(params)
    else
      Rails.logger.warn("Unhandled GitLab webhook event: #{event_type}")
    end
  rescue => e
    Rails.logger.error("Failed to process GitLab webhook for event #{event_type}: #{e.message}")
    raise
  end

  def handle_push_event(payload)
    last_commit = commits.order("committed_at DESC").first
    last_committed_at = last_commit&.committed_at.to_s || 1.year.ago.to_s

    Rails.logger.info("Triggering FetchGitlabProjectEntitiesJob for push event. Last commit at: #{last_committed_at}")

    # Queue a job to fetch updated branches, commits, and tags
    FetchGitlabProjectEntitiesJob.perform_async(id, ["branch", "commit", "tag"], last_committed_at)
  end

  def handle_merge_request_event(payload)
    mr_data = payload[:object_attributes]

    merge_request = merge_requests.find_or_initialize_by(remote_id: mr_data[:iid])
    if merge_request.persisted?
      merge_request.refresh
      Rails.logger.info("Refreshed merge request #{merge_request.title} (ID=#{merge_request.remote_id}) for project #{name}")
    else
      merge_request.update!(
        title: mr_data[:title],
        description: mr_data[:description],
        state: mr_data[:state],
        opened_at: mr_data[:created_at],
        closed_at: mr_data[:closed_at],
        merged_at: mr_data[:merged_at],
        merge_user: payload.dig(:user, :username),
        draft: mr_data[:work_in_progress],
        can_merge: mr_data[:merge_status] == "can_be_merged",
        merge_requestable: self
      )
      merge_request.refresh
      Rails.logger.info("Created and refreshed merge request #{merge_request.title} (ID=#{merge_request.remote_id}) for project #{name}")
    end
  end

  def handle_release_event(payload)
    release_data = payload[:release]
    tag_name = release_data[:tag]

    tag = tags.find_by(name: tag_name)
    unless tag
      Rails.logger.warn("Tag #{tag_name} not found for project #{name}. Skipping release.")
      return
    end

    release = tag.releases.find_or_initialize_by(remote_id: release_data[:id])
    if release.persisted?
      release.refresh
      Rails.logger.info("Refreshed release #{release.name} (ID=#{release.remote_id}) for tag #{tag_name} in project #{name}")
    else
      release.update!(
        name: release_data[:name],
        description: release_data[:description],
        released_at: release_data[:released_at],
        tag: tag
      )
      release.refresh
      Rails.logger.info("Created and refreshed release #{release.name} (ID=#{release.remote_id}) for tag #{tag_name} in project #{name}")
    end
  end

  def handle_pipeline_event(payload)
    pipeline_data = payload[:object_attributes]

    pipeline = pipelines.find_or_initialize_by(remote_id: pipeline_data[:id])
    if pipeline.persisted?
      pipeline.refresh
      Rails.logger.info("Refreshed pipeline #{pipeline.name} (ID=#{pipeline.remote_id}) for project #{name}")
    else
      pipeline.update!(
        name: "Pipeline #{pipeline_data[:id]}",
        start_time: pipeline_data[:created_at],
        end_time: pipeline_data[:finished_at],
        status: pipeline_data[:status],
        branch: branches.find_by(name: payload.dig(:ref)&.split("/")&.last),
        remote_user: payload.dig(:user, :email)
      )
      pipeline.refresh
      Rails.logger.info("Created and refreshed pipeline #{pipeline.name} (ID=#{pipeline.remote_id}) for project #{name}")
    end
  end

  def handle_job_event(payload)
    job_data = payload[:build]

    if job_data.nil?
      Rails.logger.warn("No job data found in payload. Skipping.")
      return
    end

    pipeline = pipelines.find_by(remote_id: job_data[:pipeline_id])
    unless pipeline
      Rails.logger.warn("Pipeline with ID #{job_data[:pipeline_id]} not found. Skipping job event.")
      return
    end

    Rails.logger.info("Processing job event: Job ID=#{job_data[:id]}, Name=#{job_data[:name]}, Status=#{job_data[:status]}")

    # Update pipeline status based on job completion
    if job_data[:status] == "success" && pipeline.status != "completed"
      pipeline.update!(
        status: "completed",
        end_time: job_data[:finished_at] || Time.now
      )
    elsif job_data[:status] == "failed" && pipeline.status != "failed"
      pipeline.update!(status: "failed")
    end

    pipeline.refresh
    Rails.logger.info("Refreshed pipeline #{pipeline.name} (ID=#{pipeline.remote_id}) after job event.")
  end
end

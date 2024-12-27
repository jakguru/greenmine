class GithubRepository < ActiveRecord::Base
  include Redmine::SafeAttributes
  # Associations
  belongs_to :github_instance, class_name: "GithubInstance", foreign_key: "github_id"
  has_many :project_repositories, class_name: "ProjectGithubRepository", foreign_key: "github_repository_id"
  has_many :projects, through: :project_repositories
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
  validates :github_id, presence: true
  validates :repository_id, presence: true  # This represents the Gitlab API project ID
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
        project_github_repository = ProjectGithubRepository.where(project_id: project.id, github_repository_id: self[:id]).first
        project_github_repository.destroy
      end
    end
    # Add any new projects
    projects.each do |project|
      if !existing_projects.any? { |p| p.id == project.id }
        project_github_repository = ProjectGithubRepository.new(project_id: project.id, github_repository_id: self[:id])
        project_github_repository.save
      end
    end
    ActionCable.server.broadcast("rtu_project_github_repository", {github_instance_id: github_instance.id, github_repository_id: self[:id]})
  end

  def web_url
    "https://github.com/#{path_with_namespace}"
  end

  def git_http_url
    "https://github.com/#{path_with_namespace}.git"
  end

  def git_ssh_url
    "git@github.com:#{path_with_namespace}.git"
  end

  def remote_info
    client = github_instance.api_client
    client.repository(self[:repository_id]).to_h
  end

  def configuration_instance
    github_instance
  end

  def do_process_webhook(params, headers)
    # Normalize header keys to lowercase strings for consistent access
    headers = headers.transform_keys { |key| key.to_s.downcase }

    event_type = headers["x-github-event"]
    delivery_id = headers["x-github-delivery"]

    if event_type.blank?
      Rails.logger.error("Missing X-GitHub-Event header. Unable to process webhook.")
      return
    end

    Rails.logger.info("Received GitHub webhook for repository #{name}: event=#{event_type}, delivery_id=#{delivery_id}")

    # Route the event to a specific handler method
    case event_type
    when "push"
      handle_push_event(params)
    when "pull_request"
      handle_pull_request_event(params)
    when "release"
      handle_release_event(params)
    when "workflow_run"
      handle_workflow_run_event(params)
    when "workflow_job"
      handle_workflow_job_event(params)
    else
      Rails.logger.warn("Unhandled GitHub webhook event: #{event_type}")
    end
  rescue => e
    Rails.logger.error("Failed to process GitHub webhook for event #{event_type}: #{e.message}")
    raise
  end

  private

  def handle_push_event(payload)
    last_commit = commits.order("committed_at DESC").first
    last_committed_at = last_commit&.committed_at.to_s || 1.year.ago.to_s
    FetchGithubRepositoryEntitiesJob.perform_async(id, ["branch", "commit", "tag"], last_committed_at)
  end

  def handle_pull_request_event(payload)
    action = payload[:action]
    pr_data = payload[:pull_request]

    if pr_data.nil?
      Rails.logger.warn("No pull_request data found in payload. Skipping.")
      return
    end

    merge_request = merge_requests.find_or_initialize_by(remote_id: pr_data[:number])
    merge_request.update!(
      title: pr_data[:title],
      description: pr_data[:body],
      state: pr_data[:state],
      opened_at: pr_data[:created_at],
      closed_at: pr_data[:closed_at],
      merged_at: pr_data[:merged_at],
      merge_user: pr_data.dig(:user, :login),
      draft: pr_data[:draft],
      can_merge: pr_data[:mergeable] || false,
      merge_requestable: self
    )

    Rails.logger.info("Processed pull request event: action=#{action}, PR=#{pr_data[:number]} in repository #{name}")
  end

  def handle_release_event(payload)
    release_data = payload[:release]
    tag_name = release_data[:tag_name]

    if release_data.nil?
      Rails.logger.warn("No release data found in payload. Skipping.")
      return
    end

    tag = tags.find_by(name: tag_name)
    unless tag
      Rails.logger.warn("Tag #{tag_name} not found for repository #{name}. Skipping release.")
      return
    end

    release = tag.releases.find_or_initialize_by(remote_id: release_data[:id])
    release.update!(
      name: release_data[:name],
      description: release_data[:body],
      released_at: release_data[:published_at],
      tag: tag
    )

    Rails.logger.info("Processed release event: #{release_data[:name]} for tag #{tag_name} in repository #{name}")
  end

  def handle_workflow_run_event(payload)
    workflow_run = payload[:workflow_run]

    if workflow_run.nil?
      Rails.logger.warn("No workflow_run data found in payload. Skipping.")
      return
    end

    pipeline = pipelines.find_or_initialize_by(remote_id: workflow_run[:id])
    pipeline.update!(
      name: workflow_run[:name],
      start_time: workflow_run[:run_started_at],
      end_time: workflow_run[:updated_at],
      status: (workflow_run[:status] == "completed") ? workflow_run[:conclusion] : workflow_run[:status],
      branch: branches.find_by(name: workflow_run.dig(:head_branch)),
      remote_user: workflow_run.dig(:head_commit, :author, :email)
    )

    Rails.logger.info("Processed workflow run event: #{workflow_run[:name]} for repository #{name}")
  end

  def handle_workflow_job_event(payload)
    workflow_job = payload[:workflow_job]

    if workflow_job.nil?
      Rails.logger.warn("No workflow_job data found in payload. Skipping.")
      return
    end

    Rails.logger.info("Workflow job event: ID=#{workflow_job[:id]}, Name=#{workflow_job[:name]}, Status=#{workflow_job[:status]}")

    # Optionally, update the associated pipeline if the job affects the overall pipeline
    pipeline = pipelines.find_by(remote_id: workflow_job[:run_id])
    return unless pipeline

    if workflow_job[:status] == "completed" && pipeline.end_time.nil?
      pipeline.update!(
        end_time: workflow_job[:completed_at] || Time.now,
        status: workflow_job[:conclusion]
      )
    end

    Rails.logger.info("Processed workflow job event for pipeline #{pipeline.name} in repository #{name}") if pipeline
  end
end

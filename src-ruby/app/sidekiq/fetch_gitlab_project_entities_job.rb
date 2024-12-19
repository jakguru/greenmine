class FetchGitlabProjectEntitiesJob
  include Sidekiq::Job

  def perform(id, only = ["branch", "commit", "merge_request", "tag", "pipeline", "release"], since = nil)
    gitlab_project = GitlabProject.find(id)
    return if gitlab_project.nil?

    gitlab = gitlab_project.gitlab_instance
    return if gitlab.nil?

    api_client = gitlab.api_client

    if only.include?("branch") || only.include?("commit")
      sync_branches_and_commits(gitlab_project, api_client, since)
    end

    if only.include?("merge_request")
      sync_merge_requests(gitlab_project, api_client)
    end

    if only.include?("tag")
      sync_tags(gitlab_project, api_client)
    end

    if only.include?("pipeline")
      sync_pipelines(gitlab_project, api_client, since)
    end

    if only.include?("release")
      sync_releases(gitlab_project, api_client, since)
    end
  end

  private

  def sync_branches_and_commits(gitlab_project, api_client, since)
    Rails.logger.info("Fetching branches for GitLab project #{gitlab_project.id}")

    api_client.branches(gitlab_project.path_with_namespace).auto_paginate do |branch_data|
      branch = RemoteGit::Branch.find_or_create_by!(
        branchable_id: gitlab_project.id,
        branchable_type: "GitlabProject",
        name: branch_data.name
      )

      Rails.logger.info("Fetching commits for branch #{branch.name} in project #{gitlab_project.id}")
      params = {ref_name: branch_data.name}
      params[:since] = since if since
      api_client.commits(gitlab_project.path_with_namespace, params).auto_paginate do |commit_data|
        commit = sync_commit(gitlab_project, api_client, commit_data)
        branch.commits << commit if commit && !branch.commits.include?(commit)
      end
    end
  end

  def sync_commit(gitlab_project, api_client, commit_data)
    Rails.logger.info("Syncing commit #{commit_data.id} for project #{gitlab_project.id}")

    committer_name = commit_data.committer_name || "Unknown Author"
    committer_email = commit_data.committer_email || "unknown@example.com"
    parent_sha = commit_data.parent_ids&.first

    # Find or create committer
    committer = RemoteGit::Committer.find_or_create_by!(email: committer_email) do |new_committer|
      new_committer.name = committer_name
    end

    # Prepare attributes for commit
    commit_attrs = {
      message: commit_data.message,
      committed_at: commit_data.committed_date,
      committer: committer,
      parent_sha: parent_sha,
      commitable_type: "GitlabProject",
      commitable_id: gitlab_project.id,
      author_name: commit_data.author_name,
      author_email: commit_data.author_email,
      remote_user: nil # GitLab API does not provide a `committer_id`
    }

    # Find or initialize commit record
    commit = RemoteGit::Commit.find_or_initialize_by(sha: commit_data.id)
    commit.assign_attributes(commit_attrs)
    if commit.save
      commit
    else
      Rails.logger.error("Failed to sync commit #{commit_data.id}: #{commit.errors.full_messages.join(", ")}")
      nil
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("Validation error for commit #{commit_data.id}: #{e.message}")
    nil
  end

  def sync_merge_requests(gitlab_project, api_client)
    Rails.logger.info("Fetching merge requests for GitLab project #{gitlab_project.id}")

    merge_requests = []
    api_client.merge_requests(gitlab_project.path_with_namespace, {state: "all"}).auto_paginate do |mr|
      merge_requests << mr
    end

    merge_requests.each do |mr|
      Rails.logger.debug("Processing merge request: #{mr.inspect}")

      closing_commit = mr.merge_commit_sha.present? ? RemoteGit::Commit.find_by(sha: mr.merge_commit_sha) : nil
      if mr.merge_commit_sha.present? && closing_commit.nil?
        Rails.logger.info("Found reference to unrecognized commit #{mr.merge_commit_sha} in merge request #{mr.id}. Syncing commit.")
        commit_data = api_client.commit(gitlab_project.path_with_namespace, mr.merge_commit_sha)
        closing_commit = sync_commit(gitlab_project, api_client, commit_data)
        if closing_commit.nil?
          Rails.logger.warn("Failed to sync commit #{mr.merge_commit_sha} for merge request #{mr.id}. Skipping merge request.")
          next
        end
      end

      source_branch = RemoteGit::Branch.find_or_create_by!(
        branchable_id: gitlab_project.id,
        branchable_type: "GitlabProject",
        name: mr.source_branch
      )

      target_branch = RemoteGit::Branch.find_or_create_by!(
        branchable_id: gitlab_project.id,
        branchable_type: "GitlabProject",
        name: mr.target_branch
      )

      merge_request_model_raw = {
        title: mr.title,
        description: mr.description || "",
        state: mr.state,
        remote_id: mr.id,
        opened_at: mr.created_at,
        closed_at: mr.closed_at,
        merged_at: mr.merged_at,
        merge_user: mr.merge_user&.[](:username),
        draft: mr.draft || mr.work_in_progress,
        can_merge: mr.merge_status == "can_be_merged",
        status: mr.state,
        closing_commit: closing_commit,
        source_branch: source_branch,
        target_branch: target_branch,
        merge_requestable: gitlab_project
      }

      merge_request_model = RemoteGit::MergeRequest.find_or_create_by!(remote_id: mr.id) do |mr_model|
        mr_model.assign_attributes(merge_request_model_raw)
      end
      merge_request_model.update!(merge_request_model_raw)
      Rails.logger.info("Synced merge request #{mr.title} (ID: #{mr.id}) for project #{gitlab_project.id}")
    end
  rescue => e
    Rails.logger.error("Error syncing merge requests for project #{gitlab_project.id}: #{e.message}")
    raise
  end

  def sync_tags(gitlab_project, api_client)
    Rails.logger.info("Fetching tags for GitLab project #{gitlab_project.id}")

    api_client.tags(gitlab_project.path_with_namespace).auto_paginate do |tag_data|
      commit = RemoteGit::Commit.find_by(sha: tag_data.commit.id)
      unless commit
        Rails.logger.warn("Commit #{tag_data.commit.id} for tag #{tag_data.name} not found. Skipping tag.")
        next
      end

      RemoteGit::Tag.find_or_create_by!(
        name: tag_data.name,
        commit: commit,
        taggable: gitlab_project
      ).update!(
        tagged_at: tag_data.commit.committed_date
      )
    end
  end

  def sync_pipelines(gitlab_project, api_client, since = nil)
    Rails.logger.info("Fetching pipelines for GitLab project #{gitlab_project.id}")

    pipelines = []
    params = {}
    params[:updated_after] = since.iso8601 if since

    # Use auto_paginate to fetch all pipelines
    api_client.pipelines(gitlab_project.path_with_namespace, params).auto_paginate do |pipeline_data|
      pipelines << pipeline_data
    end

    pipelines.each do |pipeline_data|
      Rails.logger.debug("Processing pipeline summary: #{pipeline_data.inspect}")

      # Fetch full pipeline details using `.pipeline`
      full_pipeline_data = api_client.pipeline(gitlab_project.path_with_namespace, pipeline_data.id)
      Rails.logger.debug("Full pipeline data: #{full_pipeline_data.inspect}")

      # Extract commit SHA and associated data
      commit_sha = full_pipeline_data.sha
      next unless commit_sha

      # Ensure the commit exists; sync it if missing
      commit = RemoteGit::Commit.find_by(sha: commit_sha)
      unless commit
        Rails.logger.info("Commit #{commit_sha} for pipeline #{full_pipeline_data.id} not found. Syncing commit.")
        commit_details = api_client.commit(gitlab_project.path_with_namespace, commit_sha)
        commit = sync_commit(gitlab_project, api_client, commit_details)
        if commit.nil?
          Rails.logger.warn("Failed to sync commit #{commit_sha} for pipeline #{full_pipeline_data.id}. Skipping pipeline.")
          next
        end
      end

      # Initialize relationships
      branch = nil
      tag = nil
      merge_request = nil

      if full_pipeline_data.ref&.start_with?("refs/merge-requests/")
        # Handle merge request references
        mr_id = full_pipeline_data.ref.split("/").last.to_i
        merge_request = RemoteGit::MergeRequest.find_by(
          remote_id: mr_id,
          merge_requestable: gitlab_project
        )
        unless merge_request
          Rails.logger.info("Fetching merge request #{mr_id} for pipeline #{full_pipeline_data.id}")
          mr_data = api_client.merge_request(gitlab_project.path_with_namespace, mr_id)
          merge_request = sync_merge_request(gitlab_project, api_client, mr_data)
        end
      else
        # Check if ref is a branch or tag
        branch = RemoteGit::Branch.find_by(
          branchable_id: gitlab_project.id,
          branchable_type: "GitlabProject",
          name: full_pipeline_data.ref
        )
        tag = RemoteGit::Tag.find_by(
          taggable_type: "GitlabProject",
          taggable_id: gitlab_project.id,
          name: full_pipeline_data.ref
        )
      end

      # Extract user details for remote_user
      user_data = full_pipeline_data.user || {}
      user_id = user_data.id || 0

      # Prepare pipeline attributes
      pipeline_attrs = {
        name: full_pipeline_data.name || "Pipeline #{full_pipeline_data.id}",
        commit: commit,
        branch: branch,
        tag: tag,
        merge_request: merge_request,
        remote_user: user_id,
        start_time: full_pipeline_data.created_at,
        end_time: full_pipeline_data.updated_at,
        status: full_pipeline_data.status
      }

      # Find or initialize pipeline
      pipeline = RemoteGit::Pipeline.find_or_initialize_by(
        commit: commit,
        name: pipeline_attrs[:name]
      )

      # Assign and save pipeline attributes
      pipeline.assign_attributes(pipeline_attrs)
      if pipeline.save
        Rails.logger.info("Synced pipeline #{pipeline.name} for project #{gitlab_project.id}")
      else
        Rails.logger.error("Failed to sync pipeline #{full_pipeline_data.id}: #{pipeline.errors.full_messages.join(", ")}")
      end
    end
  rescue => e
    Rails.logger.error("Error syncing pipelines for project #{gitlab_project.id}: #{e.message}")
    raise
  end

  def sync_releases(gitlab_project, api_client, since = nil)
    Rails.logger.info("Fetching releases for GitLab project #{gitlab_project.id}")

    releases = []
    params = {}
    params[:updated_after] = since.iso8601 if since

    # Use `auto_paginate` to fetch all releases
    api_client.project_releases(gitlab_project.path_with_namespace).auto_paginate do |release_data|
      releases << release_data
    end

    releases.each do |release_data|
      Rails.logger.debug("Processing release: #{release_data.inspect}")

      # Find the tag for this release
      tag = RemoteGit::Tag.find_by(
        name: release_data.tag_name,
        taggable: gitlab_project
      )
      unless tag
        Rails.logger.warn("Tag #{release_data.tag_name} for release #{release_data.name} not found. Skipping release.")
        next
      end

      # Create or update the release
      release_attrs = {
        name: release_data.name || "Release #{release_data.id}",
        description: release_data.description || "",
        released_at: release_data.released_at || release_data.created_at,
        tag: tag
      }

      release = RemoteGit::Release.find_or_initialize_by(name: release_attrs[:name], tag: tag)
      if release.update(release_attrs)
        Rails.logger.info("Synced release #{release.name} for project #{gitlab_project.id}")
      else
        Rails.logger.error("Failed to sync release #{release_data.name || release_data.id}: #{release.errors.full_messages.join(", ")}")
      end
    end
  rescue => e
    Rails.logger.error("Error syncing releases for project #{gitlab_project.id}: #{e.message}")
    raise
  end
end

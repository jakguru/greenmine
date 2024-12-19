class FetchGithubRepositoryEntitiesJob
  include Sidekiq::Job

  def perform(id, only = ["branch", "commit", "merge_request", "tag", "pipeline", "release"], since = nil)
    github_repository = GithubRepository.find(id)
    return nil if github_repository.nil?

    github = github_repository.github_instance
    return nil if github.nil?

    api_client = github.api_client

    if only.include?("branch") || only.include?("commit")
      sync_branches_and_commits(github_repository, api_client, since)
    end

    if only.include?("merge_request")
      sync_merge_requests(github_repository, api_client)
    end

    if only.include?("tag")
      sync_tags(github_repository, api_client)
    end

    if only.include?("pipeline")
      sync_pipelines(github_repository, api_client)
    end

    if only.include?("release")
      sync_releases(github_repository, api_client)
    end
  end

  private

  def sync_branches_and_commits(github_repository, api_client, since)
    Rails.logger.info("Fetching branches for Github repository #{github_repository.id}")

    branches = []
    res = api_client.branches(github_repository.path_with_namespace)
    branches.concat(res)
    while api_client.last_response.rels[:next].present?
      res = api_client.get(api_client.last_response.rels[:next].href)
      branches.concat(res)
    end

    branches.each do |branch_data|
      # Sync the branch
      branch = RemoteGit::Branch.find_or_create_by!(
        branchable_id: github_repository.id,
        branchable_type: "GithubRepository",
        name: branch_data[:name]
      )

      # Fetch and sync commits for this branch
      Rails.logger.info("Fetching commits for branch #{branch.name} in repository #{github_repository.id}")
      commits = []
      params = {sha: branch_data[:commit][:sha]}
      params[:since] = since if since
      res = api_client.commits(github_repository.path_with_namespace, params)
      commits.concat(res)
      while api_client.last_response.rels[:next].present?
        res = api_client.get(api_client.last_response.rels[:next].href)
        commits.concat(res)
      end

      # Sync commits and associate them with the branch
      commits.each do |commit_data|
        commit = sync_commit(github_repository, api_client, commit_data)

        if commit.nil?
          Rails.logger.warn("Skipping association for branch #{branch.name}: Commit not found or invalid")
          next
        end

        branch.commits << commit unless branch.commits.include?(commit)
      end
    end
  end

  def sync_commit(github_repository, api_client, commit_data)
    Rails.logger.info("Syncing commit #{commit_data[:sha]} for repository #{github_repository.id}")

    commit_details = commit_data[:commit]
    return nil if commit_details.nil?

    committer_data = commit_details[:committer] || {}
    message = commit_details[:message]
    committer_name = committer_data[:name] || "Unknown Author"
    committer_email = committer_data[:email] || "unknown@example.com"
    parent_sha = commit_data[:parents]&.first&.[](:sha)

    # Find or create committer
    committer = RemoteGit::Committer.find_or_create_by!(email: committer_email) do |new_committer|
      new_committer.name = committer_name
    end

    # Prepare attributes for commit
    commit_attrs = {
      message: message,
      committed_at: committer_data[:date],
      committer: committer,
      parent_sha: parent_sha,
      commitable_type: "GithubRepository",
      commitable_id: github_repository.id,
      author_name: committer_name,
      author_email: committer_email,
      remote_user: committer_data[:committer]&.[](:id) || nil # Use the `id` field for remote_user
    }
    # Handle creation or update separately to avoid conflicts
    commit = RemoteGit::Commit.find_or_initialize_by(sha: commit_data[:sha])
    commit.assign_attributes(commit_attrs)
    if commit.save
      commit
    else
      Rails.logger.error("Failed to sync commit #{commit.sha}: #{commit.errors.full_messages.join(", ")}")
      nil
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("Validation error for commit #{commit_data[:sha]}: #{e.message}")
    nil
  end

  def sync_merge_requests(github_repository, api_client)
    Rails.logger.info("Fetching merge requests for Github repository #{github_repository.id}")
    merge_requests = []
    res = api_client.pull_requests(github_repository.path_with_namespace, {state: "open"})
    merge_requests.concat(res)
    while api_client.last_response.rels[:next].present?
      res = api_client.get(api_client.last_response.rels[:next].href)
      merge_requests.concat(res)
    end
    res = api_client.pull_requests(github_repository.path_with_namespace, {state: "closed"})
    merge_requests.concat(res)
    while api_client.last_response.rels[:next].present?
      res = api_client.get(api_client.last_response.rels[:next].href)
      merge_requests.concat(res)
    end
    merge_requests.each do |mr|
      unless mr[:title].present?
        Rails.logger.warn("Skipping merge request: #{mr.inspect}")
        next
      end
      closing_commit = mr[:merge_commit_sha].present? ? RemoteGit::Commit.find_by(sha: mr[:merge_commit_sha]) : nil
      if mr[:merge_commit_sha].present? && closing_commit.nil?
        Rails.logger.info("Found reference to unrecognized commit #{mr[:merge_commit_sha]} in merge request #{mr[:id]}. Syncronizing commit.")
        closing_commit = sync_commit(github_repository, api_client, api_client.commit(github_repository.path_with_namespace, mr[:merge_commit_sha]))
        if closing_commit.nil?
          Rails.logger.warn("Failed to sync commit #{mr[:merge_commit_sha]} for merge request #{mr[:id]}. Skipping merge request.")
          next
        end
      end
      source_branch = RemoteGit::Branch.find_by(
        branchable_id: github_repository.id,
        branchable_type: "GithubRepository",
        name: mr[:head][:ref]
      )
      if source_branch.nil?
        Rails.logger.info("Found reference to unrecognized branch #{mr[:head][:ref]} in merge request #{mr[:id]}. Syncronizing branch.")
        source_branch = RemoteGit::Branch.find_or_create_by!(
          branchable_id: github_repository.id,
          branchable_type: "GithubRepository",
          name: mr[:head][:ref]
        )
      end
      target_branch = RemoteGit::Branch.find_by(
        branchable_id: github_repository.id,
        branchable_type: "GithubRepository",
        name: mr[:base][:ref]
      )
      if target_branch.nil?
        Rails.logger.info("Found reference to unrecognized branch #{mr[:base][:ref]} in merge request #{mr[:id]}. Syncronizing branch.")
        target_branch = RemoteGit::Branch.find_or_create_by!(
          branchable_id: github_repository.id,
          branchable_type: "GithubRepository",
          name: mr[:base][:ref]
        )
      end
      merge_request_model_raw = {
        title: mr[:title],
        description: mr[:body] || "",
        state: mr[:state],
        remote_id: mr[:id],
        opened_at: mr[:created_at],
        closed_at: mr[:closed_at],
        merged_at: mr[:merged_at],
        merge_user: mr[:user][:login],
        draft: mr[:draft],
        can_merge: mr[:mergeable] || false,
        status: mr[:state],
        closing_commit: closing_commit,
        source_branch: source_branch,
        target_branch: target_branch,
        merge_requestable: github_repository
      }
      merge_request_model = RemoteGit::MergeRequest.find_or_create_by!(remote_id: mr[:id]) do |mr_model|
        mr_model.assign_attributes(merge_request_model_raw)
      end
      merge_request_model.update!(merge_request_model_raw)
    end
  end

  def sync_tags(github_repository, api_client)
    Rails.logger.info("Fetching tags for Github repository #{github_repository.id}")

    tags = []
    res = api_client.tags(github_repository.path_with_namespace)
    tags.concat(res)

    while api_client.last_response.rels[:next].present?
      res = api_client.get(api_client.last_response.rels[:next].href)
      tags.concat(res)
    end

    tags.each do |tag_data|
      # Fetch commit SHA from tag data
      commit_sha = tag_data[:commit][:sha]
      next unless commit_sha

      # Check if commit exists in the database, otherwise sync it
      commit = RemoteGit::Commit.where(sha: commit_sha).preload(:committer).first
      unless commit
        Rails.logger.info("Commit #{commit_sha} for tag #{tag_data[:name]} not found. Syncing commit.")
        commit_details = api_client.commit(github_repository.path_with_namespace, commit_sha)
        commit = sync_commit(github_repository, api_client, commit_details)
        if commit.nil?
          Rails.logger.warn("Failed to sync commit #{commit_sha} for tag #{tag_data[:name]}. Skipping tag.")
          next
        end
      end

      # Create or update the tag
      tag_attrs = {
        commit: commit,
        parent_sha: commit[:parent_sha], # Optionally reference parent commit
        committer_id: commit.committer_id,
        tagged_at: commit[:committed_at],
        taggable_type: "GithubRepository",
        taggable_id: github_repository.id
      }

      tag_record = RemoteGit::Tag.where(
        taggable_type: "GithubRepository",
        taggable_id: github_repository.id,
        name: tag_data[:name]
      ).first_or_initialize(tag_attrs)

      tag_record.update!(tag_attrs)
      Rails.logger.info("Synced tag: #{tag_data[:name]} for repository #{github_repository.id}")
    end
  end

  def sync_pipelines(github_repository, api_client)
    Rails.logger.info("Fetching pipelines for Github repository #{github_repository.id}")

    # Fetch pipelines
    pipelines = []
    res = api_client.get("/repos/#{github_repository.path_with_namespace}/actions/runs")
    pipelines.concat(res[:workflow_runs] || [])

    while api_client.last_response.rels[:next].present?
      res = api_client.get(api_client.last_response.rels[:next].href)
      pipelines.concat(res[:workflow_runs] || [])
    end

    pipelines.each do |pipeline_data|
      Rails.logger.debug("Processing pipeline: #{pipeline_data.inspect}")

      # Extract head commit SHA
      commit_sha = pipeline_data[:head_sha]
      head_branch = pipeline_data[:head_branch]
      next unless commit_sha

      # Ensure the commit exists; sync it if missing
      commit = RemoteGit::Commit.find_by(sha: commit_sha)
      unless commit
        Rails.logger.info("Commit #{commit_sha} for pipeline #{pipeline_data[:id]} not found. Syncing commit.")
        commit_details = api_client.commit(github_repository.path_with_namespace, commit_sha)
        commit = sync_commit(github_repository, api_client, commit_details)
        if commit.nil?
          Rails.logger.warn("Failed to sync commit #{commit_sha} for pipeline #{pipeline_data[:id]}. Skipping pipeline.")
          next
        end
      end

      # Initialize relationships
      branch = nil
      tag = nil
      merge_request = nil

      if head_branch&.start_with?("refs/pull/")
        # Handle pull request reference
        pull_request_id = head_branch.split("/")[2]
        Rails.logger.info("Pipeline references a pull request: #{pull_request_id}")

        # Fetch pull request details from the API
        pull_request = api_client.pull_request(github_repository.path_with_namespace, pull_request_id.to_i)
        if pull_request
          merge_request = RemoteGit::MergeRequest.find_or_create_by!(
            remote_id: pull_request[:id],
            merge_requestable: github_repository
          ) do |mr|
            mr.title = pull_request[:title]
            mr.description = pull_request[:body] || ""
            mr.state = pull_request[:state]
            mr.opened_at = pull_request[:created_at]
            mr.closed_at = pull_request[:closed_at]
            mr.merged_at = pull_request[:merged_at]
            mr.merge_user = pull_request[:user][:login]
            mr.draft = pull_request[:draft]
            mr.can_merge = pull_request[:mergeable] || false
            mr.status = pull_request[:state]
          end
        else
          Rails.logger.warn("Failed to resolve pull request #{pull_request_id} for pipeline #{pipeline_data[:id]}.")
        end
      else
        # Check if head_branch is a branch or tag
        branch = RemoteGit::Branch.find_by(
          branchable_id: github_repository.id,
          branchable_type: "GithubRepository",
          name: head_branch
        )
        tag = RemoteGit::Tag.find_by(
          taggable_type: "GithubRepository",
          taggable_id: github_repository.id,
          name: head_branch
        )
      end

      # Extract GitHub user details for remote_user
      actor_data = pipeline_data[:triggering_actor] || {}
      github_user_id = actor_data[:id] || 0

      # Prepare pipeline attributes
      pipeline_attrs = {
        name: pipeline_data[:name] || "Pipeline #{pipeline_data[:id]}",
        commit: commit,
        branch: branch,
        tag: tag,
        merge_request: merge_request,
        remote_user: github_user_id,
        start_time: pipeline_data[:run_started_at],
        end_time: pipeline_data[:updated_at],
        status: (pipeline_data[:status] == "completed") ? pipeline_data[:conclusion] : pipeline_data[:status] # Adjust status
      }

      # Find or initialize pipeline
      pipeline = RemoteGit::Pipeline.find_or_initialize_by(
        commit: commit,
        name: pipeline_attrs[:name]
      )

      # Assign and save pipeline attributes
      pipeline.assign_attributes(pipeline_attrs)
      if pipeline.save
        Rails.logger.info("Synced pipeline #{pipeline.name} for repository #{github_repository.id}")
      else
        Rails.logger.error("Failed to sync pipeline #{pipeline_data[:id]}: #{pipeline.errors.full_messages.join(", ")}")
      end
    end
  end

  def sync_releases(github_repository, api_client)
    Rails.logger.info("Fetching releases for Github repository #{github_repository.id}")
    releases = []
    res = api_client.releases(github_repository.path_with_namespace)
    releases.concat(res)
    while api_client.last_response.rels[:next].present?
      res = api_client.get(api_client.last_response.rels[:next].href)
      releases.concat(res)
    end
    releases.each do |release|
      tag = RemoteGit::Tag.find_by(name: release[:tag_name], taggable: github_repository)
      next unless tag

      RemoteGit::Release.find_or_create_by!(
        name: release[:name],
        tag: tag
      ).update!(
        description: release[:body],
        released_at: release[:published_at]
      )
    end
  end
end

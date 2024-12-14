class CreateRemoteGitPipelines < ActiveRecord::Migration[6.0]
  def change
    create_table :remote_git_pipelines do |t|
      t.string :name, null: false # Pipeline name
      t.references :branch, foreign_key: {to_table: :remote_git_branches}, null: true # Optional branch relationship
      t.references :tag, foreign_key: {to_table: :remote_git_tags}, null: true # Optional tag relationship
      t.references :commit, foreign_key: {to_table: :remote_git_commits}, null: false # Required commit relationship
      t.string :author_name, null: false # Name of the user who triggered the pipeline
      t.string :author_email, null: false # Email of the user who triggered the pipeline
      t.string :remote_user, null: false # Remote user identifier for GitHub/GitLab
      t.datetime :start_time, null: false # When the pipeline started
      t.datetime :end_time # When the pipeline ended
      t.string :status, null: false # Status of the pipeline (e.g., "running", "failed", "success")
      t.timestamps
    end

    # Add a composite index to ensure a unique pipeline per branch/tag and commit
    add_index :remote_git_pipelines, [:branch_id, :tag_id, :commit_id], unique: true, name: "index_remote_git_pipelines_on_branch_tag_commit"
  end
end

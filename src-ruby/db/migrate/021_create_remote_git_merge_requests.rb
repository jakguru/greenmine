class CreateRemoteGitMergeRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :remote_git_merge_requests do |t|
      t.string :title, null: false
      t.text :description
      t.string :state, null: false # e.g., "open", "merged", "closed"
      t.string :remote_id, null: false # Unique ID from GitHub/GitLab
      t.datetime :opened_at, null: false
      t.datetime :closed_at
      t.datetime :merged_at
      t.string :author_name, null: false
      t.string :author_email, null: false
      t.string :merge_user # Remote user who performed the merge
      t.boolean :draft, default: false
      t.boolean :can_merge, default: false # Indicates if the merge request can currently be merged
      t.string :status # Current status (GitLab/GitHub mergeable state)
      t.references :closing_commit, foreign_key: {to_table: :remote_git_commits} # Commit that closes the request
      t.references :source_branch, null: false, foreign_key: {to_table: :remote_git_branches}
      t.references :target_branch, null: false, foreign_key: {to_table: :remote_git_branches}
      t.references :merge_requestable, polymorphic: true, null: false, index: {name: "index_remote_git_merge_requests_on_merge_requestable"}
      t.timestamps
    end

    # Add a unique index for remote_id to prevent duplicate entries
    add_index :remote_git_merge_requests, :remote_id, unique: true
  end
end

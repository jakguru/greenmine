class CreateRemoteGitCommitsAndBranchesCommits < ActiveRecord::Migration[6.0]
  def change
    # Create commits table
    create_table :remote_git_commits do |t|
      t.string :sha, null: false
      t.string :message, null: false
      t.datetime :committed_at, null: false
      t.string :author_name, null: false
      t.string :author_email, null: false
      t.string :remote_user, null: false # Remote user identifier for GitHub/GitLab
      t.references :commitable, polymorphic: true, null: false, index: {name: "index_remote_git_commits_on_commitable"}
      t.references :parent_commit, foreign_key: {to_table: :remote_git_commits}, null: true # Parent commit reference
      t.timestamps
    end

    # Add a unique index on sha to prevent duplicate commits
    add_index :remote_git_commits, :sha, unique: true

    # Create join table for branches and commits
    create_table :remote_git_branches_commits, id: false do |t|
      t.references :branch, null: false, foreign_key: {to_table: :remote_git_branches}
      t.references :commit, null: false, foreign_key: {to_table: :remote_git_commits}

      t.index [:branch_id, :commit_id], unique: true, name: "index_remote_git_branches_commits_on_branch_and_commit"
    end
  end
end

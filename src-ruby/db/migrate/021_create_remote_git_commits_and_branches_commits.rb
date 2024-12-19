class CreateRemoteGitCommitsAndBranchesCommits < ActiveRecord::Migration[6.0]
  def change
    # Create commits table
    create_table :remote_git_commits do |t|
      t.string :sha, null: false
      t.text :message, null: false, collation: "utf8mb4_bin"
      t.datetime :committed_at, null: false
      t.string :author_name, null: false, collation: "utf8mb4_bin"
      t.string :author_email, null: false
      t.string :remote_user, null: true # Remote user identifier for GitHub/GitLab
      t.references :commitable, polymorphic: true, null: false, index: {name: "index_remote_git_commits_on_commitable"}
      t.string :parent_sha, null: true
      t.timestamps
    end

    # Add a unique index on sha to prevent duplicate commits
    add_index :remote_git_commits, :sha, unique: true
    # Add an index on parent_sha for faster lookups
    add_index :remote_git_commits, :parent_sha
    # Update remote_git_commits to reference the committer
    add_reference :remote_git_commits, :committer, foreign_key: {to_table: :remote_git_committers}, type: :bigint

    # Create join table for branches and commits
    create_table :remote_git_branches_commits, id: false do |t|
      t.references :branch, null: false, foreign_key: {to_table: :remote_git_branches}
      t.references :commit, null: false, foreign_key: {to_table: :remote_git_commits}

      t.index [:branch_id, :commit_id], unique: true, name: "index_remote_git_branches_commits_on_branch_and_commit"
    end
  end
end

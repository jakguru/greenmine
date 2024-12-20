class CreateRemoteGitTags < ActiveRecord::Migration[6.0]
  def change
    # Create tags table
    create_table :remote_git_tags do |t|
      t.string :name, null: false                   # Name of the tag
      t.string :parent_sha                         # Parent commit SHA reference
      t.string :remote_id, null: false # Unique ID from GitHub/GitLab
      t.references :commit, foreign_key: {to_table: :remote_git_commits}, null: false
      t.references :committer, foreign_key: {to_table: :remote_git_committers}, null: true
      t.datetime :tagged_at                        # Timestamp for when the tag was created
      t.string :taggable_type, null: false         # Polymorphic association
      t.bigint :taggable_id, null: false           # Polymorphic ID
      t.timestamps
    end

    # Add index for the polymorphic association
    add_index :remote_git_tags, [:taggable_type, :taggable_id]

    # Ensure uniqueness for tags under the same taggable scope
    add_index :remote_git_tags, [:name, :taggable_type, :taggable_id], unique: true
  end
end

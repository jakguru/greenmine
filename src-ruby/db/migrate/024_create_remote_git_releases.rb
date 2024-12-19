class CreateRemoteGitReleases < ActiveRecord::Migration[6.0]
  def change
    # Create releases table
    create_table :remote_git_releases do |t|
      t.string :name, null: false, collation: "utf8mb4_bin" # Release name (e.g., "v1.0.0")
      t.text :description, collation: "utf8mb4_bin" # Release description or notes
      t.datetime :released_at, null: true # Release timestamp
      t.references :tag, null: false, foreign_key: {to_table: :remote_git_tags} # Reference to the associated tag
      t.timestamps
    end

    # Create join table for releases and Redmine versions
    create_table :remote_git_releases_versions, id: false do |t|
      t.references :release, null: false, foreign_key: {to_table: :remote_git_releases}
      t.integer :version_id, null: false # Explicitly specify the type to match Redmine's `versions.id`
      t.foreign_key :versions, column: :version_id

      t.index [:release_id, :version_id], unique: true, name: "index_remote_git_releases_versions_on_release_and_version"
    end
  end
end

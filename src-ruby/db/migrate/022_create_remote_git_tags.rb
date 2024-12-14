class CreateRemoteGitTags < ActiveRecord::Migration[6.0]
  def change
    create_table :remote_git_tags do |t|
      t.string :name, null: false
      t.text :message # Annotated tag message, if any
      t.datetime :tagged_at, null: false # When the tag was created in the repository
      t.string :author_name, null: false
      t.string :author_email, null: false
      t.references :commit, null: false, foreign_key: {to_table: :remote_git_commits} # Link to the commit
      t.references :taggable, polymorphic: true, null: false, index: {name: "index_remote_git_tags_on_taggable"}
      t.timestamps
    end

    # Add a unique index for name to prevent duplicate tags for the same taggable entity
    add_index :remote_git_tags, [:name, :taggable_type, :taggable_id], unique: true, name: "index_remote_git_tags_on_name_and_taggable"
  end
end

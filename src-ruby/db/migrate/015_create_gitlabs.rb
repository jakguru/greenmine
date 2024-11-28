class CreateGitlabs < ActiveRecord::Migration[6.1]
  def change
    # Drop the tables if they already exist
    drop_table :gitlabs, if_exists: true
    drop_table :project_gitlabs, if_exists: true
    drop_table :gitlab_projects, if_exists: true

    # Create the gitlabs table with an ID column (default to bigint)
    create_table :gitlabs do |t|
      t.string :name, null: false
      t.string :url, null: false
      t.string :api_token, null: false
      t.boolean :active, null: false, default: true
      t.timestamps
    end

    # Association table for projects and gitlab instances
    create_table :project_gitlabs do |t|
      t.bigint :gitlab_id, null: false, foreign_key: true  # Matches gitlabs.id which is an integer
      t.bigint :project_id, null: false, foreign_key: true  # Matches gitlabs.id which is a bigint
      t.timestamps
    end

    # Model Table for gitlab projects
    create_table :gitlab_projects do |t|
      t.bigint :gitlab_id, null: false, foreign_key: true  # Matches gitlabs.id which is an integer
      t.bigint :project_id, null: false, foreign_key: false # This is the project id from the gitlab API
      t.string :name, null: false
      t.string :name_with_namespace, null: false
      t.string :path, null: false
      t.string :path_with_namespace, null: false
      t.timestamps
    end

    # Adding foreign key constraints explicitly
    add_foreign_key :project_gitlabs, :gitlabs, column: :gitlab_id
    add_foreign_key :project_gitlabs, :gitlabs, column: :project_id
    add_foreign_key :gitlab_projects, :gitlabs, column: :gitlab_id
  end
end

class CreateGitlabs < ActiveRecord::Migration[6.1]
  def change
    # Drop the tables if they already exist
    drop_table :gitlabs, if_exists: true
    drop_table :gitlab_projects, if_exists: true
    drop_table :gitlab_users, if_exists: true
    drop_table :user_gitlab_users, if_exists: true
    drop_table :project_gitlab_project, if_exists: true

    # Create the gitlabs table with an ID column (default to bigint)
    create_table :gitlabs do |t|
      t.string :name, null: false
      t.string :url, null: false
      t.string :api_token, null: false
      t.boolean :active, null: false, default: true
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

    # Model Table for gitlab users
    create_table :gitlab_users do |t|
      t.bigint :gitlab_id, null: false, foreign_key: true  # Matches gitlabs.id which is an integer
      t.bigint :user_id, null: false, foreign_key: false # This is the project id from the gitlab API
      t.string :username, null: false
      t.string :name, null: false
      t.timestamps
    end

    create_table :user_gitlab_users do |t|
      t.integer :user_id, null: false, foreign_key: true  # Matches users.id which is an integer
      t.bigint :gitlab_user_id, null: false, foreign_key: true  # Matches gitlab_users.id which is a bigint
      t.timestamps
    end

    create_table :project_gitlab_project do |t|
      t.integer :project_id, null: false, foreign_key: true  # Matches projects.id which is an integer
      t.bigint :gitlab_project_id, null: false, foreign_key: true  # Matches gitlab_projects.id which is a bigint
      t.timestamps
    end

    # Adding foreign key constraints explicitly
    add_foreign_key :gitlab_projects, :gitlabs, column: :gitlab_id
    add_foreign_key :project_gitlab_project, :projects, column: :project_id
    add_foreign_key :project_gitlab_project, :gitlab_projects, column: :gitlab_project_id
    add_foreign_key :user_gitlab_users, :users, column: :user_id
    add_foreign_key :user_gitlab_users, :gitlab_users, column: :gitlab_user_id
  end
end

class CreateGithubs < ActiveRecord::Migration[6.1]
  def change
    # Drop the tables if they already exist
    drop_table :githubs, if_exists: true
    drop_table :github_repositories, if_exists: true
    drop_table :github_users, if_exists: true
    drop_table :user_github_users, if_exists: true
    drop_table :project_github_repository, if_exists: true

    # Create the githubs table with an ID column (default to bigint)
    create_table :githubs do |t|
      t.string :name, null: false
      t.string :api_token, null: false
      t.boolean :active, null: false, default: true
      t.timestamps
    end

    # Model Table for github projects
    create_table :github_repositories do |t|
      t.bigint :github_id, null: false, foreign_key: true  # Matches githubs.id which is an integer
      t.bigint :project_id, null: false, foreign_key: false # This is the project id from the github API
      t.string :name, null: false
      t.string :name_with_namespace, null: false
      t.string :path, null: false
      t.string :path_with_namespace, null: false
      t.timestamps
    end

    # Model Table for github users
    create_table :github_users do |t|
      t.bigint :github_id, null: false, foreign_key: true  # Matches githubs.id which is an integer
      t.bigint :user_id, null: false, foreign_key: false # This is the project id from the github API
      t.string :username, null: false
      t.string :name, null: false
      t.timestamps
    end

    create_table :user_github_users do |t|
      t.integer :user_id, null: false, foreign_key: true  # Matches users.id which is an integer
      t.bigint :github_user_id, null: false, foreign_key: true  # Matches github_users.id which is a bigint
      t.timestamps
    end

    create_table :project_github_repository do |t|
      t.integer :project_id, null: false, foreign_key: true  # Matches projects.id which is an integer
      t.bigint :github_repository_id, null: false, foreign_key: true  # Matches github_repositories.id which is a bigint
      t.timestamps
    end

    # Adding foreign key constraints explicitly
    add_foreign_key :github_repositories, :githubs, column: :github_id
    add_foreign_key :project_github_repository, :projects, column: :project_id
    add_foreign_key :project_github_repository, :github_repositories, column: :github_repository_id
    add_foreign_key :user_github_users, :users, column: :user_id
    add_foreign_key :user_github_users, :github_users, column: :github_user_id
  end
end

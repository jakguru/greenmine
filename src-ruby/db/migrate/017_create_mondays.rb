class CreateMondays < ActiveRecord::Migration[6.1]
  def change
    # Drop the tables if they already exist
    drop_table :mondays, if_exists: true
    drop_table :monday_boards, if_exists: true
    drop_table :monday_users, if_exists: true
    drop_table :user_monday_users, if_exists: true

    # Create the mondays table with an ID column (default to bigint)
    create_table :mondays do |t|
      t.string :name, null: false
      t.string :api_token, null: false
      t.boolean :active, null: false, default: true
      t.timestamps
    end

    # Model Table for monday boards
    create_table :monday_boards do |t|
      t.bigint :monday_id, null: false, foreign_key: true  # Matches mondays.id which is an integer
      t.integer :project_id, null: true, foreign_key: false  # Matches projects.id which is an integer
      t.string :monday_board_id, null: false
      t.json :board_meta_data, null: false
      t.json :board_field_mapping, null: false
      t.timestamps
    end

    # Model Table for monday users
    create_table :monday_users do |t|
      t.bigint :monday_id, null: false, foreign_key: true  # Matches mondays.id which is an integer
      t.bigint :user_id, null: false, foreign_key: false # This is the project id from the monday API
      t.json :user_meta_data, null: false
      t.timestamps
    end

    create_table :user_monday_users do |t|
      t.integer :user_id, null: false, foreign_key: true  # Matches users.id which is an integer
      t.bigint :monday_user_id, null: false, foreign_key: true  # Matches monday_users.id which is a bigint
      t.timestamps
    end

    # Adding foreign key constraints explicitly
    add_foreign_key :monday_boards, :mondays, column: :monday_id
  end
end

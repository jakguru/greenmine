class CreateSprints < ActiveRecord::Migration[6.1]
  def change
    # Drop the tables if they already exist
    drop_table :sprints, if_exists: true
    drop_table :issue_sprints, if_exists: true

    # Create the sprints table with an ID column (default to bigint)
    create_table :sprints do |t|
      t.string :name, null: false
      t.datetime :start_date, null: false
      t.datetime :end_date, null: false
      t.timestamps
    end

    # Create the issue_sprints table with integer references to issues and bigint for sprints
    create_table :issue_sprints do |t|
      t.integer :issue_id, null: false, foreign_key: true  # Matches issues.id which is an integer
      t.bigint :sprint_id, null: false, foreign_key: true  # Matches sprints.id which is a bigint
      t.timestamps
    end

    # Adding foreign key constraints explicitly
    add_foreign_key :issue_sprints, :issues, column: :issue_id
    add_foreign_key :issue_sprints, :sprints, column: :sprint_id
  end
end

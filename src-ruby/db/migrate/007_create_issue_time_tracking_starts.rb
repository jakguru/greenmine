class CreateIssueTimeTrackingStarts < ActiveRecord::Migration[6.1]
  def change
    drop_table :issue_time_tracking_starts, if_exists: true

    create_table :issue_time_tracking_starts do |t|
      t.integer :issue_id, null: false
      t.integer :user_id, null: false
      t.datetime :start_time
      t.integer :activity_id

      t.timestamps
    end

    add_foreign_key :issue_time_tracking_starts, :issues, column: :issue_id
    add_foreign_key :issue_time_tracking_starts, :users, column: :user_id
    add_index :issue_time_tracking_starts, :issue_id
    add_index :issue_time_tracking_starts, :user_id
  end
end

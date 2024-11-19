class AddWorkflowColumnsToTrackers < ActiveRecord::Migration[4.2]
  def self.up
    add_column :trackers, :nodes_json, :json, null: false
    add_column :trackers, :edges_json, :json, null: false
    add_column :trackers, :new_issue_statuses_json, :json, null: false
  end

  def self.down
    remove_column :trackers, :nodes_json
    remove_column :trackers, :edges_json
    remove_column :trackers, :new_issue_statuses_json
  end
end

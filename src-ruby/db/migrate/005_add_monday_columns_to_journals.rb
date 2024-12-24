class AddMondayColumnsToJournals < ActiveRecord::Migration[4.2]
  def self.up
    add_column :journals, :monday_instance_id, :bigint, null: true
    add_column :journals, :monday_item_id, :string, default: "", null: true
    add_column :journals, :monday_update_id, :string, default: "", null: true
  end

  def self.down
    remove_column :journals, :monday_instance_id
    remove_column :journals, :monday_item_id
    remove_column :journals, :monday_update_id
  end
end

class AddMondayColumnsToJournals < ActiveRecord::Migration[4.2]
  def self.up
    add_column :journals, :monday_update_id, :string, default: "", null: false
  end

  def self.down
    remove_column :journals, :monday_update_id
  end
end

class AddMondayColumnsToIssues < ActiveRecord::Migration[4.2]
  def self.up
    add_column :issues, :monday_item_id, :string, default: "", null: false
  end

  def self.down
    remove_column :issues, :monday_item_id
  end
end

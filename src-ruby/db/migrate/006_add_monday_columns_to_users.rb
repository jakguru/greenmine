class AddMondayColumnsToUsers < ActiveRecord::Migration[4.2]
  def self.up
    add_column :users, :monday_person_id, :string, default: "", null: false
  end

  def self.down
    remove_column :users, :monday_person_id
  end
end

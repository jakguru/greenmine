class AddStyleColumnsToTrackers < ActiveRecord::Migration[4.2]
  def self.up
    add_column :trackers, :icon, :string, null: true
    add_column :trackers, :color, :string, null: true
  end

  def self.down
    remove_column :trackers, :icon
    remove_column :trackers, :color
  end
end

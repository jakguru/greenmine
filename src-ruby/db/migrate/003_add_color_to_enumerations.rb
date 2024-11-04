class AddColorToEnumerations < ActiveRecord::Migration[4.2]
  def self.up
    add_column :enumerations, :color, :string, null: true
  end

  def self.down
    remove_column :enumerations, :color
  end
end

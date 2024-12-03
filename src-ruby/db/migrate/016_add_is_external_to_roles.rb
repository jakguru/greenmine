class AddIsExternalToRoles < ActiveRecord::Migration[4.2]
  def self.up
    add_column :roles, :is_external, :boolean, default: false
  end

  def self.down
    remove_column :roles, :is_external
  end
end

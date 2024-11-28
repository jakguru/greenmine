class AddImagesToProjects < ActiveRecord::Migration[4.2]
  def self.up
    add_column :projects, :avatar, :text, null: true
    add_column :projects, :banner, :text, null: true
  end

  def self.down
    remove_column :projects, :avatar
    remove_column :projects, :banner
  end
end

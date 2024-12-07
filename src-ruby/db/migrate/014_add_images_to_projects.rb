class AddImagesToProjects < ActiveRecord::Migration[4.2]
  def self.up
    add_column :projects, :avatar, :longblob, null: true
    add_column :projects, :banner, :longblob, null: true
  end

  def self.down
    remove_column :projects, :avatar
    remove_column :projects, :banner
  end
end

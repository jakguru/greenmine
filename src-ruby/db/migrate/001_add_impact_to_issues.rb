class AddImpactToIssues < ActiveRecord::Migration[4.2]
  def self.up
    add_column :issues, :impact_id, :integer, default: 0, null: false
  end

  def self.down
    remove_column :issues, :impact_id
  end
end

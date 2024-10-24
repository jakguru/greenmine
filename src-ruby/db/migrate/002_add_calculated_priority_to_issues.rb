class AddCalculatedPriorityToIssues < ActiveRecord::Migration[4.2]
  def self.up
    add_column :issues, :calculated_priority, :integer, default: 10, null: false
  end

  def self.down
    remove_column :issues, :calculated_priority
  end
end

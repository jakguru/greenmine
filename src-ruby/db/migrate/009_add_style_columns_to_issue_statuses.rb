class AddStyleColumnsToIssueStatuses < ActiveRecord::Migration[4.2]
  def self.up
    add_column :issue_statuses, :icon, :string, null: true
    add_column :issue_statuses, :text_color, :string, null: true
    add_column :issue_statuses, :background_color, :string, null: true
  end

  def self.down
    remove_column :issue_statuses, :icon
    remove_column :text_color, :icon
    remove_column :background_color, :icon
  end
end

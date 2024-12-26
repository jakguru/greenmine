class AddPolymorphicAssociationToIssues < ActiveRecord::Migration[6.1]
  def change
    create_table :remote_git_associations do |t|
      t.references :associable, polymorphic: true, null: false, index: true
      t.integer :issue_id, null: false
      t.timestamps
    end

    add_foreign_key :remote_git_associations, :issues, column: :issue_id
  end
end

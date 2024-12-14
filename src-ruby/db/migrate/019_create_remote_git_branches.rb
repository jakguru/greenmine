class CreateRemoteGitBranches < ActiveRecord::Migration[6.0]
  def change
    create_table :remote_git_branches do |t|
      t.string :name, null: false
      t.references :branchable, polymorphic: true, null: false, index: {name: "index_remote_git_branches_on_branchable"}
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end

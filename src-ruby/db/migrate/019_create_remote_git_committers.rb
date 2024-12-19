class CreateRemoteGitCommitters < ActiveRecord::Migration[6.0]
  def change
    create_table :remote_git_committers do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.references :user, foreign_key: {to_table: :users}, type: :integer, null: true # Match the type of users.id
      t.timestamps
    end
  end
end

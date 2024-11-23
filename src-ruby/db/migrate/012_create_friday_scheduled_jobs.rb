class CreateFridayScheduledJobs < ActiveRecord::Migration[6.1]
  def change
    create_table :friday_scheduled_jobs do |t|
      t.string :name, null: false, unique: true
      t.datetime :last_run_at

      t.timestamps
    end

    add_index :friday_scheduled_jobs, :name, unique: true
  end
end

class AddCompletedByToTasks < ActiveRecord::Migration[5.0]
  def change
    add_column :tasks, :completed_by_id, :integer
    add_index :tasks, :completed_by_id

    remove_column :tasks, :completed, :bool
    add_column :tasks, :completed_at, :datetime
    add_index :tasks, :completed_at
  end
end

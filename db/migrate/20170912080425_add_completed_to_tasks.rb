class AddCompletedToTasks < ActiveRecord::Migration[5.0]
  def change
    add_column :tasks, :completed, :boolean, default: false
    add_index :tasks, :completed
  end
end

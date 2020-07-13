class AddPermissionsIndexToTasks < ActiveRecord::Migration[5.0]
  def change
    add_index :tasks, :permission
  end
end

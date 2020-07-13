class AddPermissionToTasks < ActiveRecord::Migration[5.0]
  def change
    add_column :tasks, :permission, :integer
  end
end

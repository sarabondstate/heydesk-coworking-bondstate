class AddTaskIdToTaskImages < ActiveRecord::Migration[5.0]
	def change
    add_column :task_images, :task_id, :integer,:null => false
    add_index :task_images, :task_id
  end
end

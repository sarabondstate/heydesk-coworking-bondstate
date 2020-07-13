class AddUpdatedByIdToTasks < ActiveRecord::Migration[5.0]
  def change
  	add_column :tasks, :updated_by_id, :integer
  end
end

class AddIndexForCreatedAtOnTasks < ActiveRecord::Migration[5.0]
  def change
    add_index :tasks, :created_at
    add_index :tasks, :updated_at
  end
end

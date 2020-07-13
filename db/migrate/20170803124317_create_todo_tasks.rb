class CreateTodoTasks < ActiveRecord::Migration[5.0]
  def change
    create_table :todo_tasks do |t|

      t.timestamps
    end
  end
end

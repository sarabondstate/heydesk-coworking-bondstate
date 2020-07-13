class RemoveUnusedModels < ActiveRecord::Migration[5.0]
  def change
    # remove unused task models
    drop_table :todo_tasks
    drop_table :other_tasks
    drop_table :observation_tasks
    drop_table :training_tasks
    drop_table :race_tasks

    # remove unused user models
    drop_table :admins
    drop_table :external_employees
    drop_table :employees
  end
end

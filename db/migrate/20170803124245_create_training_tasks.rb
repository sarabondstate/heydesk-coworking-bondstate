class CreateTrainingTasks < ActiveRecord::Migration[5.0]
  def change
    create_table :training_tasks do |t|

      t.timestamps
    end
  end
end

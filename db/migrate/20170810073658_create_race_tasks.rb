class CreateRaceTasks < ActiveRecord::Migration[5.0]
  def change
    create_table :race_tasks do |t|

      t.timestamps
    end
  end
end

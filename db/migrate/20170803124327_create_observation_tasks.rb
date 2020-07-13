class CreateObservationTasks < ActiveRecord::Migration[5.0]
  def change
    create_table :observation_tasks do |t|

      t.timestamps
    end
  end
end

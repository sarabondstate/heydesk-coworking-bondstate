class CreateOtherTasks < ActiveRecord::Migration[5.0]
  def change
    create_table :other_tasks do |t|

      t.timestamps
    end
  end
end

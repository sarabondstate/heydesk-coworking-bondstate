class CreateTaskImages < ActiveRecord::Migration[5.0]
  def change
    create_table :task_images do |t|

      t.timestamps
    end
  end
end

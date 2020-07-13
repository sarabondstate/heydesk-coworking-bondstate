class CreateTaskLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :task_logs do |t|
      t.integer :task_id
      t.integer :user_id
      t.string :key, default: ''
      t.string :from, default: ''
      t.string :to, default: ''
      t.string :custom_name, default: ''
      t.timestamps
    end
  end
end

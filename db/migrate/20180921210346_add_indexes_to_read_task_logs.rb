class AddIndexesToReadTaskLogs < ActiveRecord::Migration[5.0]
  def change
    add_index :task_logs, :user_id
    add_index :task_logs, :task_id
    add_index :task_logs, :created_at
    add_index :task_logs, :updated_at
    add_index :task_logs, :key
    add_index :task_logs, :from
    add_index :task_logs, :to
    add_index :task_logs, :custom_name
  end
end

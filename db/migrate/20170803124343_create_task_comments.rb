class CreateTaskComments < ActiveRecord::Migration[5.0]
  def change
    create_table :task_comments do |t|
      t.integer :task_id, :null => false
      t.integer :comment_id, :null => false
      t.timestamps
    end
  end
end

class AddTextToComments < ActiveRecord::Migration[5.0]
  def change
    add_column :comments, :text, :text

    add_reference :comments, :user
    add_reference :comments, :task
    add_reference :comments, :tag

    drop_table :task_comments
  end
end

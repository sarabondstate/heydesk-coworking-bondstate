class ExtendTasks < ActiveRecord::Migration[5.0]
  def change
    remove_reference :tasks, :tag
    remove_column :tasks, :user

    create_join_table :tags, :tasks do |t|
      t.index [:tag_id, :task_id]
    end

    add_column :tasks, :date, :date
    add_column :tasks, :time, :time

    add_index :tasks, [:date, :time]

    add_column :tasks, :note, :text

    add_reference :tasks, :user

    add_index :tasks, :horse_id
    add_index :tasks, :taskable_id
  end
end

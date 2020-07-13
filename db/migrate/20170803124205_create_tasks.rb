class CreateTasks < ActiveRecord::Migration[5.0]
  def change
    create_table :tasks do |t|
      t.references :taskable, polymorphic: true
      t.integer :tag_id
      t.integer :horse_id
      t.integer :user
      t.timestamps
    end
  end
end

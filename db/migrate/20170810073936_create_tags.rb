class CreateTags < ActiveRecord::Migration[5.0]
  def change
    create_table :tags do |t|
      t.integer :tag_type_id
      t.string :tag_name, :null => false, :default => ''
      t.timestamps
    end
  end
end

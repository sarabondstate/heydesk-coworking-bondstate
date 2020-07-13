class AddIndexesOnTags < ActiveRecord::Migration[5.0]
  def change
    add_index :tags, :created_at
    add_index :tags, :updated_at
    add_index :tags, :tag_type_id
  end
end

class AddIndexesToHorsesTags < ActiveRecord::Migration[5.0]
  def change
    add_index :horses_tags, :created_at
    add_index :horses_tags, :updated_at
    add_index :horses_tags, :tag_updated
  end
end

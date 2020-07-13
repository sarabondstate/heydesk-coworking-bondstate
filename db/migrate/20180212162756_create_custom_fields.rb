class CreateCustomFields < ActiveRecord::Migration[5.0]
  def change
    create_table :custom_fields do |t|
      t.string :name
      t.references :stable, foreign_key: true
      t.references :custom_field_type, foreign_key: true
      t.references :tag_type, foreign_key: true
      t.timestamps
    end
    
    create_join_table :tags, :custom_fields do |t|
      t.index [:custom_field_id, :tag_id] # The order here is relevant, because we will mostly look up tags from templates.
    end
  end
end

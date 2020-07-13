class CreateTemplates < ActiveRecord::Migration[5.0]
  def change
    create_table :templates do |t|
      t.references :stable
      t.references :tag_type
      t.string :name, null: false
      t.string :note

      t.timestamps
    end

    create_join_table :horses, :templates do |t|
      t.index [:template_id, :horse_id] # The order here is relevant, because we will mostly look up horses from templates.
    end
    create_join_table :tags, :templates do |t|
      t.index [:template_id, :tag_id] # The order here is relevant, because we will mostly look up tags from templates.
    end
  end
end

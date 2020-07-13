class CreateHorsesTagUpdates < ActiveRecord::Migration[5.0]
  def change
    create_table :horses_tags do |t|
      t.references :horse
      t.references :tag

      t.timestamp :tag_updated

      t.timestamps
    end
  end
end

class AddHorseSetups < ActiveRecord::Migration[5.0]
  def change
    create_table :setup_topics do |t|
      t.references :stable
      t.string :title

      t.timestamps
    end

    add_index :setup_topics, [:stable_id, :title]

    create_table :horse_setups do |t|
      t.references :setup_topic
      t.references :horse
      t.text :description

      t.timestamps
    end
  end
end

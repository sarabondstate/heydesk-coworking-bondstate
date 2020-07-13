class CreateHorseOwnerships < ActiveRecord::Migration[5.0]
  def change
    create_table :horse_ownerships do |t|
      t.integer :horse_id
      t.integer :owner_id
      t.float :percentage

      t.timestamps
    end
  end
end

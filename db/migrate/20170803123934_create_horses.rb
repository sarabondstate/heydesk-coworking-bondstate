class CreateHorses < ActiveRecord::Migration[5.0]
  def change
    create_table :horses do |t|
      t.integer :stable_id
      t.string :name, null: false
      t.string :registration_number, null: false
      t.timestamps
    end
  end
end

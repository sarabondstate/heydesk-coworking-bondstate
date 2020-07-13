class CreateShareAHorses < ActiveRecord::Migration[5.0]
  def change
    create_table :share_a_horses do |t|
      t.integer :owner_identifier
      t.string :owner_email
      t.text :data

      t.timestamps
    end
  end
end

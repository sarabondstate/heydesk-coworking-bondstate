class CreateOwnerHorses < ActiveRecord::Migration[5.0]
  def change
    create_table :owner_horses do |t|
      t.references :common_horse
      t.references :stable
      t.integer :status, default: 0
      t.integer :user_id
      t.integer :trainer_id
      t.timestamps
    end
  end
end

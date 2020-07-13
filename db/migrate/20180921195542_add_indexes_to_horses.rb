class AddIndexesToHorses < ActiveRecord::Migration[5.0]
  def change
    add_index :horses, :stable_id
    add_index :horses, :created_at
    add_index :horses, :updated_at
    add_index :horses, :avatar_updated_at
    add_index :horses, :active
  end
end

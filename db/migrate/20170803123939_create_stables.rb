class CreateStables < ActiveRecord::Migration[5.0]
  def change
    create_table :stables do |t|
      t.string :name, null: false
      t.string :address, null: false
      t.string :telephone, null: false
      t.string :zip, null: false
      t.string :city, null: false
      t.integer :trainer_id
      t.timestamps
    end
  end
end

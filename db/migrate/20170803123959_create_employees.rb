class CreateEmployees < ActiveRecord::Migration[5.0]
  def change
    create_table :employees do |t|
      t.integer :stable_id
      t.timestamps
    end
  end
end

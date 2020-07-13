class CreatePlans < ActiveRecord::Migration[5.0]
  def change
    create_table :plans do |t|
      t.integer :min_horses
      t.integer :max_horses
      t.string :details, :null => false
      t.float :price, :null => false
      t.timestamps
    end
  end
end

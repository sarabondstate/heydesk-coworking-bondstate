class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
      t.string :country
      t.string :price
      t.string :vat
    end
  end
end

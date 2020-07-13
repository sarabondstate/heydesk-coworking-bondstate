class ExtraFieldsOnUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :phone, :string
    add_column :users, :address, :string
    add_column :users, :zip, :string
    add_column :users, :city, :string
    add_column :users, :country, :string
    add_column :users, :trainer_id, :string
  end
end

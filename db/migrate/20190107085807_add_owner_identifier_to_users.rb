class AddOwnerIdentifierToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :owner_identifier, :string
    add_index :users, :owner_identifier
  end
end

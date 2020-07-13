class AddIndexesToUsers < ActiveRecord::Migration[5.0]
  def change
    add_index :users, :perishable_token
    add_index :users, :single_access_token
  end
end

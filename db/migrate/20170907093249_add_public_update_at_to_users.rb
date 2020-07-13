class AddPublicUpdateAtToUsers < ActiveRecord::Migration[5.0]
  def change

    add_column :users, :public_updated_at, :timestamp
  end
end

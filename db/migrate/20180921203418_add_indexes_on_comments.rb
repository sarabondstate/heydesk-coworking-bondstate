class AddIndexesOnComments < ActiveRecord::Migration[5.0]
  def change
    add_index :comments, :created_at
    add_index :comments, :updated_at
  end
end

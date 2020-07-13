class AddIndexesToMyLists < ActiveRecord::Migration[5.0]
  def change
    add_index :my_lists, :created_at
    add_index :my_lists, :updated_at
  end
end

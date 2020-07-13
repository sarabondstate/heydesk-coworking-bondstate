class AddIconUrlToMyList < ActiveRecord::Migration[5.0]
  def change
    add_column :my_lists, :icon, :string
  end
end

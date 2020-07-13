class RemoveTagTypeFromMyLists < ActiveRecord::Migration[5.0]
  def change
    remove_column :my_lists, :tag_type_id
  end
end

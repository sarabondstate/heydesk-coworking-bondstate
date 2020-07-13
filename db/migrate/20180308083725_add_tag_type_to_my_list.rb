class AddTagTypeToMyList < ActiveRecord::Migration[5.0]
  def change
    add_column :my_lists, :tag_type_id, :integer
  end
end

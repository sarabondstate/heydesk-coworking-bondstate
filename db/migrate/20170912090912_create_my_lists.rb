class CreateMyLists < ActiveRecord::Migration[5.0]
  def change
    create_table :my_lists do |t|
      t.references :user
      t.string :title
      t.timestamps
    end

    create_join_table :my_lists, :tags do |t|
      t.index [:my_list_id, :tag_id]
    end
    create_join_table :horses, :my_lists do |t|
      t.index [:horse_id, :my_list_id]
    end
  end
end

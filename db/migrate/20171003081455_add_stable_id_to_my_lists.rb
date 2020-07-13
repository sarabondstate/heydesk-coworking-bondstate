class AddStableIdToMyLists < ActiveRecord::Migration[5.0]
  def change
    add_reference :my_lists, :stable
    add_index :my_lists, [:user_id, :stable_id]

    # Migrate current data
    # I assume that my_list belongs_to user, and user has_and_belongs_to stables.
    MyList.joins(:user).find_each do |my_list|
      stable = my_list.user.stables.first
      my_list.update_attribute(:stable_id, stable.id)
    end
  end
end

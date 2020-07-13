class UserStableRole < ApplicationRecord
end

class AddDeletedAtToUserStableRoles < ActiveRecord::Migration[5.0]
  def change
    add_column :user_stable_roles, :deleted_at, :datetime
    add_index :user_stable_roles, :deleted_at

    add_column :user_stable_roles, :created_at, :timestamp
    add_column :user_stable_roles, :updated_at, :timestamp

    UserStableRole.all.each do |usr|
      usr.update_attributes(created_at: DateTime.now, updated_at: DateTime.now)
    end
  end
end

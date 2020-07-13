class User < ApplicationRecord
  has_and_belongs_to_many :stables
end
class UserStableRole < ApplicationRecord
end

class CreateUserStableRoles < ActiveRecord::Migration[5.0]
  def change
    create_table :user_stable_roles do |t|
      t.references :user
      t.references :stable
      t.string :role
    end

    add_index :user_stable_roles, [:stable_id, :user_id]

    add_column :users, :admin, :boolean, default: false

    User.all.find_each do |user|
      user.update_attribute(:admin, true) if user.profileable_type == 'Admin'
      user.stables.each do |stable|
        UserStableRole.create(user_id: user.id, stable_id: stable.id, role: user.profileable_type.tableize.singularize)
      end
    end

    remove_column :users, :profileable_type
    remove_column :users, :profileable_id
  end
end

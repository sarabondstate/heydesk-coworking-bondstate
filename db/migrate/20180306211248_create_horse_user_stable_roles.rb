class CreateHorseUserStableRoles < ActiveRecord::Migration[5.0]
  def change
    create_table :horse_user_stable_roles do |t|
      t.integer :user_stable_role_id
      t.integer :horse_id

      t.timestamps
    end
  end
end

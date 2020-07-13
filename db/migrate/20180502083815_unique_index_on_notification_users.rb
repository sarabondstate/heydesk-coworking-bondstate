class UniqueIndexOnNotificationUsers < ActiveRecord::Migration[5.0]
  def change
    add_index :notification_users, [:user_id, :notification_id], unique: true
  end
end

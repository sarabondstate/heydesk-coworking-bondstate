class AddUserIdToPushNotifications < ActiveRecord::Migration[5.0]
  def change
    add_column :push_notifications, :user_id, :integer,:null => false
    add_index :push_notifications, :user_id
  end
end


class RemoveTokenFromPushNotifications < ActiveRecord::Migration[5.0]
  def change
    remove_column :push_notifications, :token
  end
end
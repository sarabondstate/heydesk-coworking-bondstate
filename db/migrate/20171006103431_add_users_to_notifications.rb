class AddUsersToNotifications < ActiveRecord::Migration[5.0]
  def change
    remove_column :notifications, :user_id
    create_join_table :notifications, :users do |t|
      t.index [:notification_id, :user_id]
    end
  end
end

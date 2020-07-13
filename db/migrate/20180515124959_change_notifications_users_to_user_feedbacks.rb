class ChangeNotificationsUsersToUserFeedbacks < ActiveRecord::Migration[5.0]
  def change
  	rename_table :notifications_users, :user_feedbacks
  end
end

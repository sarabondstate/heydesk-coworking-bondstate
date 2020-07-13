class ChangeNotificationUsersToFeedbackReads < ActiveRecord::Migration[5.0]
  def change
  	rename_table :notification_users, :read_feedbacks
  end
end

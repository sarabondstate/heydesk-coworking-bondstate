class RenameNotificationIdToFeedbackId < ActiveRecord::Migration[5.0]
  def change
  	rename_column :read_feedbacks, :notification_id, :feedback_id
  	rename_column :user_feedbacks, :notification_id, :feedback_id
  end
end

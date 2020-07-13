class ChangeNotificationsToFeedbacks < ActiveRecord::Migration[5.0]
  def change
  	rename_table :notifications, :feedbacks
  end
end

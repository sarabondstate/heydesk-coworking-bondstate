class UserPushNotificationSettings < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :push_enabled, :boolean, default: false
    add_column :users, :push_feedback_mention, :boolean, default: false
    add_column :users, :push_flagged_horse_feedback, :boolean, default: false
    add_column :users, :push_flagged_horse_observation, :boolean, default: false
  end
end

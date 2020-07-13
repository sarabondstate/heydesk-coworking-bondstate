class AddMoreUserPushNotificationSettings < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :push_all_horse_feedback, :boolean, default: false
    add_column :users, :push_all_horse_observation, :boolean, default: false
  end
end

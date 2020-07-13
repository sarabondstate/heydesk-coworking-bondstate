class ChangeUserFeedbacksToUsersFeedbacks < ActiveRecord::Migration[5.0]
  def change
  	rename_table :user_feedbacks, :users_feedbacks
  end
end

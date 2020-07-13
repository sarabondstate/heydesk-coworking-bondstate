##
# Feedback is what is currently shown in the Feedback tap in the app.
#
# Models that should "notify" should define "model_notifies".
# Currently that is tasks and comments.
class Feedback < ApplicationRecord
  belongs_to :notifiable, polymorphic: true
  has_and_belongs_to_many :users, :join_table => :users_feedbacks
  belongs_to :stable
  has_many :read_feedbacks

  validates_presence_of :notifiable

  def self.add_bulk(user_ids,notif_obj,stable_id)
  	n = ::Feedback.new(notifiable: notif_obj, stable_id: stable_id)
    n.user_ids = user_ids
    n.save
  end
end

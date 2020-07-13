class ReadFeedback < ApplicationRecord
  belongs_to :user
  belongs_to :feedback
end

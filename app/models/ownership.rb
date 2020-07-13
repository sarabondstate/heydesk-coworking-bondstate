class Ownership < ApplicationRecord
  belongs_to :user
  belongs_to :common_horse
  has_many :horses, through: :common_horse
end

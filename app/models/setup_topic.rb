class SetupTopic < ApplicationRecord
  belongs_to :stable
  has_many :horse_setups, dependent: :destroy
end

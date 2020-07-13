class HorseOwnership < ApplicationRecord
  belongs_to :horse
  belongs_to :owner
end

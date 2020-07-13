class Owner < ApplicationRecord
  has_one :user, as: :profileable, dependent: :destroy
  has_many :horse_ownerships
  accepts_nested_attributes_for :user
end

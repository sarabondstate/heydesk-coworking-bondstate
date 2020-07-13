class HorseFlag < ApplicationRecord
  belongs_to :user
  belongs_to :horse

  #acts_as_paranoid

  acts_as_api
  api_accessible :only_horses do |template|
    template.add :id
    template.add :horse_id

    template.add :created_at
  end
end

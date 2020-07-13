class Race < ApplicationRecord
  belongs_to :common_horse
  default_scope { order(date: :desc)}

  acts_as_api
  api_accessible :race_info do |template|
    template.add :race_position
    template.add :track
    template.add :earnings
    template.add :date
  end
end
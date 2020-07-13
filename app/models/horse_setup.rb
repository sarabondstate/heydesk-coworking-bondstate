class HorseSetup < ApplicationRecord
  belongs_to :horse
  belongs_to :setup_topic

  acts_as_api
  api_accessible :basic do |template|
    template.add :id
    template.add 'setup_topic.title', as: :title
  end
  api_accessible :extended, extend: :basic do |template|
    template.add :description
  end
end

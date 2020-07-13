class OwnerRequest< ApplicationRecord
  belongs_to :common_horse
  belongs_to :stable
  belongs_to :user
  belongs_to :trainer

  acts_as_api
  api_accessible :owner_request_basic do |template|
    template.add :id
    template.add 'common_horse.id', as: :common_horse_id
    template.add 'common_horse.name', as: :name
    template.add 'common_horse.sportsinfo_id', as: :sportsinfo_id
    template.add :stable_id
    template.add 'common_horse.registration_number', as: :registration_number
    template.add 'common_horse.birthday', as: :birthday
    template.add 'common_horse.gender', as: :gender
    template.add 'common_horse.breeder', as: :breeder
    template.add 'common_horse.owner', as: :owner
    template.add 'common_horse.chip_number', as: :chip_number
    template.add 'common_horse.nationality', as: :nationality
    template.add 'common_horse.mom', as: :mom
    template.add 'common_horse.dad', as: :dad
    template.add 'common_horse.price', as: :price
    template.add :user_id
    template.add :trainer_id
    template.add :status
    template.add :created_at
    template.add :updated_at
    template.add :stable, template: :owner_basic
  end

  api_accessible :request_basic do |template|
    template.add :id
    template.add 'common_horse.id', as: :common_horse_id
    template.add 'common_horse.name', as: :name
    template.add 'common_horse.gender', as: :gender
    template.add :trainer_id
    template.add :status
    template.add :created_at
    template.add :updated_at
    template.add proc {|t| User.find(t.user_id).as_api_response(:owner_details)}, as: :owner
    template.add proc {|g| g.common_horse.horses.first.as_api_response(:request_horse) if g.common_horse.horses.present? }, as: :horse
  end
end

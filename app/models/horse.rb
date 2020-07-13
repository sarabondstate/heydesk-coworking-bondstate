##
# This is a horse connected to a specific stable. Stable should never be changed.
# If a horse should move stable, you should soft-delete this and create a new from CommonHorse.
class Horse < ApplicationRecord
  acts_as_paranoid
  belongs_to :stable
  has_many :horse_ownerships
  has_many :tasks, dependent: :destroy
  belongs_to :common_horse
  has_many :horse_flags, dependent: :destroy
  has_many :horse_user_stable_roles, dependent: :destroy

  validates_associated :common_horse

  # This method associates the attribute ":avatar" with a file attachment
  has_attached_file :avatar, styles: {
    thumb: '100x100>',
    medium: '300x300#',
    large: '600x600>'
  }, default_url: "http://:s3_bucket.s3.amazonaws.com/horses/avatar/default/:style/horse.png"

  # Validate the attached image is image/jpg, image/png, etc
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  scope :active, -> { where(active: true, deleted_at: nil) }
  # This returns a "title". It's used by dropdown menus
  def title
    common_horse.name
  end

  def avatar_fixed_url(style = :large)
    avatar.url(style)
  end

  def thumb_url
    avatar_fixed_url(:thumb)
  end

  def medium_thumb_url
    avatar_fixed_url(:medium)
  end

  def avatar_url
    avatar_fixed_url(:large)
  end

  def price
    common_horse.price
  end

  acts_as_api
  api_accessible :basic do |template|
    template.add :id
    template.add 'common_horse.id', as: :common_horse_id
    template.add 'common_horse.name', as: :name
    template.add :stable_id
    template.add 'common_horse.registration_number', as: :registration_number
    template.add 'common_horse.birthday', as: :birthday
    template.add 'common_horse.nationality', as: :nationality
    template.add 'common_horse.price', as: :price
    template.add proc {|t| !t.deleted_at.nil?}, as: :deleted
    template.add :avatar_url, as: 'avatar'
    template.add :thumb_url, as: 'avatar_thumb'
    template.add :sorting
    template.add :created_at
    template.add :updated_at
  end

  api_accessible :all_stable_horse_basic, extend: :basic do |template|
    template.add 'stable.trainer_id', as: :trainer_id
  end

  api_accessible :common_horse do |template|
    template.add 'common_horse.name', as: :name
    template.add 'common_horse.registration_number', as: :registration_number
    template.add 'common_horse.gender', as: :gender
    template.add 'common_horse.birthday', as: :birthday
    template.add 'common_horse.nationality', as: :nationality
    template.add 'common_horse.breeder', as: :breeder
    template.add 'common_horse.owner', as: :owner
    template.add 'common_horse.chip_number', as: :chip_number
    template.add 'common_horse.mom', as: :mom
    template.add 'common_horse.dad', as: :dad
    template.add 'common_horse.price', as: :price
    template.add :avatar_url, as: 'avatar'
    template.add :thumb_url, as: 'avatar_thumb'
  end

  # The older version of the API uses this template where gender is translated to danish.
  # The above version just sends the gender in lowercase english which is then translated in the app itself.
  api_accessible :common_horse_v3 do |template|
    template.add 'common_horse.name', as: :name
    template.add 'common_horse.registration_number', as: :registration_number
    template.add proc {|g| g.common_horse.gender.blank? ? '' : I18n.t('genders.'+g.common_horse.gender, locale: 'da', :default => '')}, as: :gender
    #template.add 'common_horse.id', as: :gender
    template.add 'common_horse.birthday', as: :birthday
    template.add 'common_horse.nationality', as: :nationality
    template.add 'common_horse.breeder', as: :breeder
    template.add 'common_horse.owner', as: :owner
    template.add 'common_horse.chip_number', as: :chip_number
    template.add 'common_horse.mom', as: :mom
    template.add 'common_horse.dad', as: :dad
    template.add 'common_horse.price', as: :price
    template.add :avatar_url, as: 'avatar'
    template.add :thumb_url, as: 'avatar_thumb'
  end

  api_accessible :owned_horse do |template|
    template.add :id
    template.add 'common_horse.id', as: :common_horse_id
    template.add 'common_horse.name', as: :name
    template.add 'common_horse.registration_number', as: :registration_number
    template.add 'common_horse.sportsinfo_id', as: :sportsinfo_id
    template.add 'common_horse.birthday', as: :birthday
    template.add 'common_horse.nationality', as: :nationality
    template.add 'common_horse.gender', as: :gender
    template.add 'common_horse.breeder', as: :breeder
    template.add 'common_horse.owner', as: :owner
    template.add 'common_horse.chip_number', as: :chip_number
    template.add 'common_horse.mom', as: :mom
    template.add 'common_horse.dad', as: :dad
    template.add 'common_horse.price', as: :price
    template.add :avatar_url, as: 'avatar'
    template.add :thumb_url, as: 'avatar_thumb'
    template.add :medium_thumb_url, as: 'avatar_medium_thumb'
    template.add :created_at
    template.add :updated_at
    template.add :stable, template: :owner_basic
  end

  api_accessible :request_horse do |template|
    template.add :id
    template.add :avatar_url, as: 'avatar'
    template.add :thumb_url, as: 'avatar_thumb'
    template.add :medium_thumb_url, as: 'avatar_medium_thumb'
    template.add :created_at
    template.add :updated_at
  end

  api_accessible :show_owned_horse , extend: :owned_horse do |template|
    # template.add :tasks, template: :mto_basic
    template.add proc {|t| t.tasks.where(type_id: 5).order(created_at: :desc)}, as: :tasks, template: :mto_basic
  end


  def stable_name
    stable.name ||= ''
  end

  def horse_hash_with_extra_info(user)
    horse = self.as_api_response(:all_stable_horse_basic)
    owner_request = OwnerRequest.find_by(user_id: user.id, common_horse_id: self.common_horse.id)
    horse[:status]= if owner_request.present?
                      owner_request.status
                    else
                      ""
                    end
    horse
  end

end

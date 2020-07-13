##
# This is the persistent representation of a horse. When connected to a stable,
# you should create "Horse" which is the CommonHorse and Stable representation.
class CommonHorse < ApplicationRecord
  has_many :horses
  has_many :stables, through: :horses
  has_many :races, dependent: :destroy
  has_many :owners
  before_save :streamline_gender
  has_many :owner_requests

  def streamline_gender

    case self.gender.downcase
    when 'hoppe'
    when 'hp'
      self.gender = 'mare'
    when 'hingst'
    when 'h'
      self.gender = 'stallion'
    when 'vallak'
    when 'v'
      self.gender = 'gelding'
    else
      # Do nothing
    end

  end

  def active_horse
    horses.where(deleted_at: nil).first
  end

  accepts_nested_attributes_for :races, reject_if: :all_blank, allow_destroy: true
  validates_presence_of :name
  validates_presence_of :registration_number
  validates_uniqueness_of :registration_number

  acts_as_api
  api_accessible :basic do |template|
    template.add :name
    template.add :registration_number
    template.add :gender
    template.add :birthday
    template.add :nationality
    template.add :breeder
    template.add :owner
    template.add :chip_number
    template.add :mom
    template.add :dad
  end

  api_accessible :race_info do |template|
    template.add :winning_percentage
    template.add :number_of_starts
    template.add 'earnings_to_api', as: :earnings
    template.add 'first_prices'
    template.add 'second_prices'
    template.add 'third_prices'
    template.add 'record_time'
    template.add 'record_time_auto'
    template.add :races
  end

  private
  def earnings_to_api
    [{currency:'DKK', earnings:'danish'}, {currency:'NOK', earnings:'norwegian'}, {currency:'SEK', earnings:'swedish'}].map do |earning|
      earning[:earnings] = self['earnings_'+earning[:earnings]]
      earning
    end.reject do |earning|
      earning[:earnings].nil? and earning[:currency]!='DKK'
    end
  end


end

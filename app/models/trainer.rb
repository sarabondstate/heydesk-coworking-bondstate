##
# Class to use in signup form
class Trainer < User
  validates_presence_of :phone
  validates_presence_of :address
  validates_presence_of :zip
  validates_presence_of :city
  validates_presence_of :country

  belongs_to :stable
  accepts_nested_attributes_for :stable
  attribute :stable_id, :integer
  attribute :agreement_accept, :boolean

  validate :agreement_is_accepted

  private
  def agreement_is_accepted
    if self.agreement_accept != true
      self.errors.add(:agreement_accept, :accepted)
    end
  end
end

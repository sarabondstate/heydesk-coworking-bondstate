class UserStableRole < ApplicationRecord
  belongs_to :user
  belongs_to :stable
  has_many :horse_user_stable_roles, dependent: :destroy
  has_many :horses, through: :horse_user_stable_roles
  acts_as_paranoid

  def trainer?
    self.role == User::ROLE_TRAINER
  end

  def employee?
    [User::ROLE_EMPLOYEE, User::ROLE_EMPLOYEE_B, User::ROLE_EMPLOYEE_C, User::ROLE_EMPLOYEE_D].include? self.role
  end

  acts_as_api
  api_accessible :logging_in do |template|
    template.add 'stable_id', as: :id
    template.add 'stable.name', as: :name
    template.add :role
    template.add 'stable.country', as: :country
    template.add proc {|t| StableType.find(t.stable.stable_type_id).stable_type}, as: :stable_type
  end
end

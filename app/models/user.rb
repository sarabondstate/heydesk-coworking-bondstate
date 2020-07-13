class User < ApplicationRecord

  attr_accessor :password_confirmation

  acts_as_authentic do |c|
    c.login_field = 'email'
    c.validate_password_field = false
  end

  acts_as_paranoid

  ROLE_TRAINER = "trainer"
  ROLE_EMPLOYEE = "employee" # This is Employee Type A
  ROLE_EMPLOYEE_B = "employee_b"
  ROLE_EMPLOYEE_C = "employee_c"
  ROLE_EMPLOYEE_D = "employee_d"
  ROLE_OWNER = "owner"
  ROLE_VET = "vet"
  ROLE_BLACKSMITH = "blacksmith"

  has_many :stables, through: :user_stable_roles
  has_many :user_stable_roles
  has_and_belongs_to_many :feedbacks, :join_table => :users_feedbacks
  delegate :can?, :cannot?, :to => :ability
  validates_presence_of :email, :firstname, :lastname
  validates_uniqueness_of :email

  before_save :update_public_updated_at, :set_name
  before_validation :set_firstname_and_lastname

  has_many :tasks
  has_many :comments
  has_many :horse_flags
  has_many :user_stable_roles
  belongs_to :import_trainer
  has_many :push_tokens
  has_many :push_notifications
  has_many :owner_requests
  # Convenience for form
  attr_accessor :role_as_string


  has_many :ownerships, dependent: :destroy
  has_many :owned_horses, through: :ownerships, :source => :horses
  # trainer requests list
  has_many :my_requests, class_name: "OwnerRequest", foreign_key: "trainer_id"

"""
  # We should remove this??
  def role_as_string
    self.profileable.class.to_s
  end


  def trainer?
    self.profileable.class == Trainer
  end

  def employee?
    self.profileable.class == Employee
  end

  def owner?
    self.profileable.class == Owner
  end
"""
  def set_name
    name = ""
    unless firstname.blank?
      name = firstname
    end
    unless name.blank?
      name = name + " "
    end
    unless lastname.blank?
      name = name + lastname
    end
    self.name = name
  end

  def set_firstname_and_lastname
    name = name_changed? ? self.name : name
    if name #&& self.firstname.blank? && self.lastname.blank?
      values = name.split(" ")
      firstname = values.delete_at(0)
      lastname = values.join(' ').squeeze(' ')
      self.firstname = firstname
      self.lastname = lastname.blank? ? "." : lastname
    end
  end


  def deleted_in?(stable)
    self.user_stable_roles.where(stable:stable).first.deleted_at.nil?
  end

  def role_in(stable)
    self.user_stable_roles.where(stable:stable).first.try(:role)
  end

  def can_use_web_login?
    true if self.is_a_trainer? || self.admin? || self.is_a_employee_a?
  end

  def can_use_app?
    self.stables.active.count > 0
  end

  def is_an_owner?
    self.owner_identifier.present?
  end

  def is_vet_in_stable?(stable)
    self.has_role_in_stable?(ROLE_VET, stable)
  end

  def is_trainer_in_stable?(stable)
    self.has_role_in_stable?(ROLE_TRAINER, stable)
  end

  def is_blacksmith_in_stable?(stable)
    self.has_role_in_stable?(ROLE_BLACKSMITH, stable)
  end

  def is_employee_b_in_stable?(stable)
    self.has_role_in_stable?(ROLE_EMPLOYEE_B, stable)
  end

  def is_employee_c_in_stable?(stable)
    self.has_role_in_stable?(ROLE_EMPLOYEE_C, stable)
  end

  def is_employee_d_in_stable?(stable)
    self.has_role_in_stable?(ROLE_EMPLOYEE_D, stable)
  end

  def is_horse_restricted_in_stable?(stable)
    self.has_role_in_stable?([ROLE_EMPLOYEE_D, ROLE_OWNER], stable)
  end

  # Not specific to stable
  def is_a_trainer?
    self.user_stable_roles.where(role: ROLE_TRAINER).joins(:stable).where(stables: {active: true}).count > 0
  end

  # Not specific to stable
  def is_a_employee_a?
    self.user_stable_roles.where(role: ROLE_EMPLOYEE).joins(:stable).where(stables: {active: true}).count > 0
  end

  def is_a_employee_b?
    self.user_stable_roles.where(role: ROLE_EMPLOYEE_B).joins(:stable).where(stables: {active: true}).count > 0
  end

  def is_a_employee_c?
    self.user_stable_roles.where(role: ROLE_EMPLOYEE_C).joins(:stable).where(stables: {active: true}).count > 0
  end

  def is_a_employee_d?
    self.user_stable_roles.where(role: ROLE_EMPLOYEE_D).joins(:stable).where(stables: {active: true}).count > 0
  end

  def has_role_in_stable?(role, stable)
    self.user_stable_roles.where(stable: stable, role: role).joins(:stable).where(stables: {active: true}).count > 0
  end

  ## Employee A and B can do the same things as a trainer, except employee B cannot use do web login.
  def has_trainer_power?
    self.user_stable_roles.where(role: [ROLE_EMPLOYEE, ROLE_EMPLOYEE_B]).joins(:stable).where(stables: {active: true}).count > 0
  end

  # Returns all the stables where the user is the trainer.
  def trainer_stables
    self.user_stable_roles.where(role: ROLE_TRAINER).joins(:stable).where(stables: {active: true}).map{ |usr| usr.stable }
  end

    # Returns all the stables where the user is the trainer.
  def self.current_stable_trainers(current_stable)
    current_stable.user_stable_roles.where(role: ROLE_TRAINER).map{ |usr_stb_role| usr_stb_role.user_id }
  end

  def self.current_stable_employees(current_stable)
    current_stable.user_stable_roles.where.not(role: ROLE_TRAINER).where.not(role: ROLE_OWNER).map{ |usr_stb_role| usr_stb_role.user_id }
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!
    UserMailer.password_reset_instructions(self).deliver_now
  end

  def get_stripe_customer

    Stripe::Customer.retrieve(
        :id => self.stripe_id,
        :expand => ['default_source']
    )

  end

  def stable_access?(stable)
    self.user_stable_roles.where(stable:stable).count > 0
  end

  # This method associates the attribute ":avatar" with a file attachment
  has_attached_file :avatar, styles: {
      thumb: '100x100>',
      medium: '300x300#',
      large: '600x600>'
  } , default_url: "" # dont send default, we show placeholder it in the app instead

  # Validate the attached image is image/jpg, image/png, etc
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

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

  acts_as_api
  api_accessible :basic do |template|
    template.add :id
    template.add :email
    template.add :name
    template.add :avatar_url, as: 'avatar'
    template.add :thumb_url, as: 'avatar_thumb'
    template.add :public_updated_at, as: :updated_at
    template.add :push_enabled
    template.add :push_feedback_mention
    template.add :push_flagged_horse_feedback
    template.add :push_flagged_horse_observation
    template.add :push_all_horse_feedback
    template.add :push_all_horse_observation
    template.add :created_at
  end

  api_accessible :user_trainer do |template|
    template.add :id
    template.add :email
    template.add :name
  end

  api_accessible :logging_in, extend: :basic do |template|
    template.add :single_access_token, as: :user_credentials
    template.add :terms_accepted
    template.add :user_stable_roles, template: :logging_in, as: :stables
  end

  api_accessible :simple do |template|
    template.add :id
    template.add :name
  end

  api_accessible :push_settings do |template|
    template.add :push_enabled
    template.add :push_feedback_mention
    template.add :push_flagged_horse_feedback
    template.add :push_flagged_horse_observation
    template.add :push_all_horse_feedback
    template.add :push_all_horse_observation
  end

  api_accessible :owner_basic do |template|
    template.add :id
    template.add :email
    template.add :name
    template.add :avatar_url, as: 'avatar'
    template.add :thumb_url, as: 'avatar_thumb'
    template.add :medium_thumb_url, as: 'avatar_medium_thumb'
    template.add :public_updated_at, as: :updated_at
    template.add :push_enabled
    template.add :created_at
  end

  api_accessible :owner_signup_basic do |template|
    template.add :id
    template.add :email
    template.add :name
    template.add :avatar_url, as: 'avatar'
    template.add :thumb_url, as: 'avatar_thumb'
    template.add :medium_thumb_url, as: 'avatar_medium_thumb'
    template.add :public_updated_at, as: :updated_at
    template.add :push_enabled
    template.add :created_at
    template.add :single_access_token, as: :user_credentials
  end

  api_accessible :owner_details do |template|
    template.add :id
    template.add :email
    template.add :name
    template.add :avatar_url, as: 'avatar'
    template.add :thumb_url, as: 'avatar_thumb'
    template.add :medium_thumb_url, as: 'avatar_medium_thumb'
  end

  api_accessible :owner_logging_in, extend: :owner_basic do |template|
    template.add :single_access_token, as: :user_credentials
  end

  api_accessible :owner_push_settings do |template|
    template.add :push_enabled
  end

  def self.to_csv(lst)
    desired_columns = ["Name" ,"Email" ,"Stripe_id","Address", "Zip","City" ,"Country", "Phone","Created At","Last Login At","Stable names"]
    CSV.generate(headers: true) do |csv|
      csv << desired_columns
      row = nil
      lst.each do |obj|
        row = obj.attributes.values_at(*desired_columns.map{|wd| wd.downcase.gsub(' ','_')})
        row[desired_columns.count - 1] = obj.stables.collect(&:name).join(', ')
        csv << row
      end
    end

  end

  PERMISSION_BITMAP_TRAINER = 0b111111
  PERMISSION_BITMAP_EMPLOYEE = 0b111111
  PERMISSION_BITMAP_EMPLOYEE_B = 0b011111
  PERMISSION_BITMAP_EMPLOYEE_C = 0b011001
  PERMISSION_BITMAP_EMPLOYEE_D = 0b011111
  PERMISSION_BITMAP_OWNER = 0b011111
  PERMISSION_BITMAP_BLACKSMITH = 0b010001
  PERMISSION_BITMAP_VET = 0b0001100
  PERMISSION_BITMAP_NONE= 0b0
  ##
  # Get the permissions associated with a user's role in a stable
  def get_permission(stable)
    role = self.user_stable_roles.where(stable: stable).first

    case role.role
    when ROLE_TRAINER
      user_permission = PERMISSION_BITMAP_TRAINER
    when ROLE_EMPLOYEE
      user_permission = PERMISSION_BITMAP_EMPLOYEE
    when ROLE_EMPLOYEE_B
      user_permission = PERMISSION_BITMAP_EMPLOYEE_B
    when ROLE_EMPLOYEE_C
      user_permission = PERMISSION_BITMAP_EMPLOYEE_C
    when ROLE_EMPLOYEE_D
      user_permission = PERMISSION_BITMAP_EMPLOYEE_D
    when ROLE_OWNER
      user_permission = PERMISSION_BITMAP_OWNER
    when ROLE_BLACKSMITH
      user_permission = PERMISSION_BITMAP_BLACKSMITH
    when ROLE_VET
      user_permission = PERMISSION_BITMAP_VET
    else
      user_permission = PERMISSION_BITMAP_NONE
    end

    user_permission
  end

  private
  def update_public_updated_at
    self.public_updated_at = DateTime.now if email_changed? or name_changed?
  end
end

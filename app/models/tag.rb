class Tag < ApplicationRecord

  TAG_SHOE = I18n.t("predefined.tags.shoes")
  TAG_TREATMENT = I18n.t("predefined.tags.treatment")
  TAG_VET = I18n.t("predefined.tags.veterinarian")
  TAG_TRAINING = I18n.t("predefined.tags.training")

  default_scope { order(tag_name: :asc) }
  belongs_to :tag_type
  belongs_to :stable
  has_one :horses_tags, dependent: :destroy
  has_and_belongs_to_many :my_lists
  has_and_belongs_to_many :comments
  has_and_belongs_to_many :templates, :dependent => :delete
  has_and_belongs_to_many :custom_fields
  before_destroy { my_lists.clear } # "dependent.destroy"

  validates_presence_of :tag_name, :tag_type

  # This returns a "title". It's used by dropdown menus
  def title
    tag_name
  end
  
  def self.tag_shoe(locale = :da)
    I18n.t("predefined.tags.shoes", locale: locale)
  end

  def self.tag_treatment(locale = :da)
    I18n.t("predefined.tags.treatment", locale: locale)
  end

  def self.tag_vet(locale = :da)
    I18n.t("predefined.tags.veterinarian", locale: locale)
  end

  def self.tag_invoicing(locale = :da)
    I18n.t("predefined.tags.invoicing", locale: locale)
  end

  def self.tag_invoice(locale = :da)
    I18n.t("predefined.tags.invoice", locale: locale)
  end

  def self.tag_training(locale = :da)
    I18n.t("predefined.tags.training", locale: locale)
  end

  acts_as_api
  api_accessible :basic do |template|
    template.add :id
    template.add :tag_name
    template.add 'tag_type.title', as: :tag_type
  end
end

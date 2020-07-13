class Template < ApplicationRecord
  belongs_to :stable
  belongs_to :tag_type
  has_and_belongs_to_many :horses
  has_and_belongs_to_many :tags, :dependent => :delete

  validates_presence_of :name, :tag_type
  validates_presence_of :tags, :message =>  I18n.t("errors.messages.selected")


  def has_treatment_tags?
    self.tags.where(tag_name: Tag.tag_treatment(self.stable.locale.to_sym)).count > 0
  end

  def has_vet_tags?
    self.tags.where(tag_name: [Tag.tag_treatment(self.stable.locale.to_sym), Tag.tag_vet(self.stable.locale.to_sym)]).count > 0
  end

  def has_shoes_tags?
    self.tags.where(tag_name: Tag.tag_shoe(self.stable.locale.to_sym)).count > 0
  end

  def has_invoice_tags?
    self.tags.where(tag_name: [Tag.tag_invoice(self.stable.locale.to_sym), Tag.tag_invoicing(self.stable.locale.to_sym)]).count > 0
  end

  def has_invoice_tags_but_not_race_template?(tag_type)
    if (tag_type.title != 'race')
      self.tags.where(tag_name: Tag.tag_invoice(self.stable.locale.to_sym)).count > 0
    end
    true
  end

  def emp_b_selected_template?(tag_type)
    return (tag_type.title != 'race' && !has_invoice_tags?) || tag_type.title == 'race'
  end

  def emp_c_selected_template?(tag_type)
    return !has_treatment_tags? && (tag_type.title == 'race' || (tag_type.title != 'race' && !has_invoice_tags?))
  end

  def self.select_templates(templates, stable, user,tag_type)
    starttime = DateTime.now
    DeveloperMessage.new_message(self.class, "select_templates: Starting to select templates")
    if user.is_vet_in_stable?(stable)
      templates = templates.select {|template| template.has_vet_tags? }
    elsif user.is_blacksmith_in_stable?(stable)
      templates = templates.select {|template| template.has_shoes_tags? }
    elsif user.is_employee_b_in_stable?(stable)
      templates = templates.select {|template| template.emp_b_selected_template?(tag_type) }
    elsif user.is_employee_c_in_stable?(stable)
      templates = templates.select {|template| template.emp_c_selected_template?(tag_type) }
    end
    DeveloperMessage.new_message(self.class, "select_templates: Done selecting templates, took #{DateTime.now.to_i - starttime.to_i} seconds")

    templates

  end

  acts_as_api
  api_accessible :basic do |template|
    template.add :id
    template.add :name
    template.add :prefilled_title
    template.add :note
    template.add 'tag_type.title', as: :tag_type
    template.add proc {|t| t.horses.pluck(:id)}, as: :horses
    template.add proc {|t| t.tags.pluck(:id)}, as: :tags
  end
end
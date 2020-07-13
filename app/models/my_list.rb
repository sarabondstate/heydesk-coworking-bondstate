class MyList < ApplicationRecord
  belongs_to :user
  belongs_to :stable
  has_and_belongs_to_many :tags
  has_and_belongs_to_many :horses

  validates_presence_of :title

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
  
  acts_as_api
  api_accessible :basic do |template|
    template.add :id
    template.add :title
    template.add proc{|mp| mp.horse_ids }, as: :horses
    template.add proc{|mp| mp.tag_ids }, as: :tags
    template.add :created_at
    template.add :updated_at
    template.add :icon
  end

  def is_predefined?(my_list)
    return my_list.user_id.nil?
  end
end

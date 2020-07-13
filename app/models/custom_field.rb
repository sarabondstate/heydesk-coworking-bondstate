class CustomField < ApplicationRecord
  belongs_to :stable
  belongs_to :custom_field_type
  belongs_to :tag_type
  has_and_belongs_to_many :tags
  has_many :custom_field_values, dependent: :destroy

  validates_presence_of :name, :tag_type, :custom_field_type

  default_scope { includes(:tag_type, :custom_field_type) }
  acts_as_api
  api_accessible :basic do |template|
    template.add :id
    template.add :name
    template.add 'tag_type.title', as: :task_type
    template.add 'custom_field_type.name', as: :custom_field_type
  end

end

class CustomFieldValue < ApplicationRecord
  belongs_to :custom_field
  belongs_to :task
  has_one :custom_field_type, through: :custom_field
  validates_presence_of :custom_field
  #validates_presence_of :custom_field, :value_one
  #validates_presence_of :value_two, if: :should_have_value_two?

  default_scope { includes(:custom_field, :custom_field_type) }

  after_create :add_tags_to_task

  acts_as_api
  api_accessible :basic do |template|
    template.add :id
    template.add 'custom_field_type.name', as: :custom_field_type
    template.add 'custom_field.id', as: :custom_field_id
    template.add :value_one
    template.add :value_two, if: :has_value_two?
  end
  api_accessible :basic_for_my_plan, extend: :basic do |template|
    template.add :write_access
  end

  def write_access
    return true
  end
  private

  def should_have_value_two?
    return self.custom_field_type.number_of_inputs > 1
  end

  def has_value_two?
    custom_field_type.number_of_inputs > 1
  end

  def add_tags_to_task
    existing_tags = self.task.tags
    self.custom_field.tags.each do |t|
      unless existing_tags.include? t
        self.task.tags << t
      end
    end
  end

end

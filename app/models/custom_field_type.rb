class CustomFieldType < ApplicationRecord
  has_many :custom_fields, dependent: :destroy
  has_many :custom_field_values, through: :custom_fields, dependent: :destroy

  def translate
    I18n.t("custom_field_types.#{self.name}")
  end

  def self.to_dropdown
    CustomFieldType.all.map{|t| [t.translate,t.id]}
  end
end

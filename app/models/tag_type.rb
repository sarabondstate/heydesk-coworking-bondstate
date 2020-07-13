class TagType < ApplicationRecord
  has_many :tags

  def translate
    I18n.t("types.#{self.title}")
  end

  def self.to_dropdown current_stable
    if current_stable.is_race_stable?
      result = TagType.where.not(id: 5)
    elsif
      result = TagType.where.not(:id => 5, :title => 'race')
    end
    return result.map{|t| [t.translate, t.id]}
  end
end

class Comment < ApplicationRecord
end
class Task < ApplicationRecord
end


class UpdateHorsesTags < ActiveRecord::Migration[5.0]
  def change
    Comment.all.each do |comment|
      self.update(comment)
    end
    Task.all.each do |task|
      self.update(task)
    end
  end

  def update object
    # First find horse
    # then find tags
    # finally update/create HorsesTags

    # HORSE
    horse = object.try(:horse) || object.try(:task).try(:horse)

    unless horse.nil?
      # TAGS
      tags = []
      tag = object.try(:tag)
      tags << tag unless tag.nil?
      tags.concat(object.try(:task).try(:tags).to_a) # The to_a will also convert nil to []
      tags.concat(object.try(:tags).to_a)

      tags.each do |tag|
        htu = ::HorsesTags.find_or_create_by(horse: horse, tag: tag)
        htu.update_attribute(:tag_updated, Time.now) if htu.tag_updated.nil?
      end
    end
  end
end

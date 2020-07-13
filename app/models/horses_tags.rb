##
# Represents information about a tag on a horse.
#
# It caches timestamp whenever information is updated to
# the related references (tasks/comments/etc)
class HorsesTags < ApplicationRecord
  belongs_to :horse
  belongs_to :tag

  ##
  # Gets HorsesTags for that horse.
  # This makes sure they are all created if they do not already exist
  def self.get_all_for_horse(horse)
    ht = HorsesTags.where(horse: horse)
    # A mismatch in tag counts?
    if ht.count!=horse.stable.tags.count
      # We need to create the missing ones
      horse.stable.tags.each do |tag|
        HorsesTags.create({tag: tag, horse: horse, tag_updated: Time.now}) if ht.where(tag: tag).count==0
      end
      ht = HorsesTags.where(horse: horse)
    end
    return ht
  end

  ##
  # Collects and sorts all related data after updated_at
  # return an array of objects (task/comment/etc)
  def self.get_newest_relations(horse, tag, limit=10)
    # Go through comments and tasks

    # Tasks related to horse
    tasks_for_horse = Task.where(horse: horse)

    tasks_for_horse = tasks_for_horse.where("completed_at is not ? or date < ?", nil, Date.today)
    
    # Tasks with correct (tag and horse)
    tasks = tasks_for_horse.joins(:tags).where(horse: horse, tags: {id:tag}).order(created_at: :desc)

    # Convert tasks
    tasks = tasks.limit(limit).to_a

    all_objects = [tasks]

    return all_objects.flatten.sort{|x,y| y.created_at<=>x.created_at}.first(limit)
  end

  def is_treatment_tag?
    self.tag.tag_name == Tag.tag_treatment(self.tag.stable.locale.to_sym)
  end

  def is_vet_tag?
    self.tag.tag_name == Tag.tag_treatment(self.tag.stable.locale.to_sym) || self.tag.tag_name == Tag.tag_vet(self.tag.stable.locale.to_sym)
  end

  def is_shoe_tag?
    self.tag.tag_name == Tag.tag_shoe(self.tag.stable.locale.to_sym)
  end

  def is_invoice_tag?
    self.tag.tag_name == Tag.tag_invoice(self.tag.stable.locale.to_sym) || self.tag.tag_name == Tag.tag_invoicing(self.tag.stable.locale.to_sym)
  end


  acts_as_api
  api_accessible :basic do |template|
    template.add 'tag.id', as: :id
    template.add 'tag.tag_name', as: :name
    template.add :tag_updated, as: :updated_at
  end
end

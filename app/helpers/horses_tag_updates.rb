include ModelNotifies
module HorsesTagUpdates
  # This module enriches the ActiveRecord::Base module of Rails.
  module Base
    ##
    # Use this in an ActiveRecord model to make it update the HorsesTags
    # for that horse and tag.
    # We assume that the model is connected directly to a horse or a task,
    # and the model is connected directly to tag/tags or a task.
    def updates_horses_tag
      class_eval do
        after_create do
          # First find horse
          # then find tags
          # finally update/create HorsesTags

          # HORSE
          horse = self.try(:horse) || self.try(:task).try(:horse)

          unless horse.nil?
            # TAGS
            tags = []
            tag = self.try(:tag)
            tags << tag unless tag.nil?
            tags.concat(self.try(:task).try(:tags).to_a) # The to_a will also convert nil to []
            tags.concat(self.try(:tags).to_a)

            tags.each do |tag|
              htu = ::HorsesTags.find_or_create_by(horse: horse, tag: tag)
              htu.update(tag_updated: Time.now)
              htu.save
            end
          end
        end
      end
    end
  end
end

ActiveRecord::Base.extend HorsesTagUpdates::Base

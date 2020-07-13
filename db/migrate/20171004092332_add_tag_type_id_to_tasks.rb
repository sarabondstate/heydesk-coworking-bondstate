class Task < ApplicationRecord
end
class TagType < ApplicationRecord
end

class AddTagTypeIdToTasks < ActiveRecord::Migration[5.0]
  def change
    add_reference :tasks, :type

    tag_type_id = TagType.first.try(:id)
    Task.find_each do |task|
      task.update_attribute(:type_id, tag_type_id)
    end
  end
end

class Horse < ApplicationRecord
end
class Task < ApplicationRecord
end


class AddStableIdToTask < ActiveRecord::Migration[5.0]
  def change
    add_reference :tasks, :stable


    Task.find_each do |task|
      stable_id = Horse.where(id: task.horse_id).first.try(:stable_id)
      task.update_attribute(:stable_id, stable_id)
    end
  end
end

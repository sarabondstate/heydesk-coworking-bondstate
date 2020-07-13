class AddStableToTags < ActiveRecord::Migration[5.0]
  def change
    add_reference :tags, :stable
  end
end

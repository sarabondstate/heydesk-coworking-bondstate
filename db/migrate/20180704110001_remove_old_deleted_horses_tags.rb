class RemoveOldDeletedHorsesTags < ActiveRecord::Migration[5.0]
  def change
    # Delete HorsesTags if the tags were deleted before
    HorsesTags.where("tag_id not in(select id from tags where id=tag_id)").destroy_all
  end
end

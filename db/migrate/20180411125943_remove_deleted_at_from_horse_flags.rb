class RemoveDeletedAtFromHorseFlags < ActiveRecord::Migration[5.0]
  def change
    remove_column :horse_flags, :deleted_at
  end
end

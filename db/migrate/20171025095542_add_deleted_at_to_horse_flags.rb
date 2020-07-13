class AddDeletedAtToHorseFlags < ActiveRecord::Migration[5.0]
  def change
    add_column :horse_flags, :deleted_at, :datetime
    add_index :horse_flags, [:user_id, :deleted_at]
  end
end

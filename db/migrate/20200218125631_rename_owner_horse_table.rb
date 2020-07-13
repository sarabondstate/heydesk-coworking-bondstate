class RenameOwnerHorseTable < ActiveRecord::Migration[5.0]
  def change
    rename_table :owner_horses, :owner_requests
  end
end

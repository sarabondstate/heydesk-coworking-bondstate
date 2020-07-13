class RenameTypeToStableType < ActiveRecord::Migration[5.0]
  def change
  	rename_column :stable_types, :type, :stable_type
  end
end

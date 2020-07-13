class AddStableTypeIdToStables < ActiveRecord::Migration[5.0]
	def change
    add_column :stables, :stable_type_id, :integer
    add_index :stables, :stable_type_id
  end
end

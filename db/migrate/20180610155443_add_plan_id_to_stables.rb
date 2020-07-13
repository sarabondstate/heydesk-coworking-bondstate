class AddPlanIdToStables < ActiveRecord::Migration[5.0]
	def change
    add_column :stables, :plan_id, :integer
    add_index :stables, :plan_id
  end
end

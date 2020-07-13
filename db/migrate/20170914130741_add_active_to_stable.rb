class AddActiveToStable < ActiveRecord::Migration[5.0]
  def change
    add_column :stables, :active, :boolean, default: false
    add_index :stables, :active
  end
end

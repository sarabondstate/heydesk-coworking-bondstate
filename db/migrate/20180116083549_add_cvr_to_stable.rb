class AddCvrToStable < ActiveRecord::Migration[5.0]
  def change
    add_column :stables, :cvr, :string
  end
end

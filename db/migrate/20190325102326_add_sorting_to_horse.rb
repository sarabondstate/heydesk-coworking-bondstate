class AddSortingToHorse < ActiveRecord::Migration[5.0]
  def change
    add_column :horses, :sorting, :integer
    add_index :horses, :sorting
  end
end

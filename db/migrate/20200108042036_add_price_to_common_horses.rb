class AddPriceToCommonHorses < ActiveRecord::Migration[5.0]
  def change
    add_column :common_horses, :price, :integer, default: 0
  end
end

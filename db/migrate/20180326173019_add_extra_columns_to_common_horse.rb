class AddExtraColumnsToCommonHorse < ActiveRecord::Migration[5.0]
  def change
    add_column :common_horses, :first_prices, :integer, default: 0
    add_column :common_horses, :second_prices, :integer, default: 0
    add_column :common_horses, :third_prices, :integer, default: 0
    add_column :common_horses, :record_time, :float, default: 0.0
    add_column :common_horses, :record_time_auto, :float, default: 0.0
  end
end

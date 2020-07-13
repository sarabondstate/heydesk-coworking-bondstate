class AddMoreInfoToCommonHorse < ActiveRecord::Migration[5.0]
  def change
    add_column :common_horses, :breeder, :string
    add_column :common_horses, :owner, :string
    add_column :common_horses, :chip_number, :string
    add_column :common_horses, :mom, :string
    add_column :common_horses, :dad, :string
  end
end

class AddGenderToCommonHorse < ActiveRecord::Migration[5.0]
  def change
    add_column :common_horses, :gender, :string
  end
end

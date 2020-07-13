class AddYearAndCountryToHorses < ActiveRecord::Migration[5.0]
  def change
    add_column :horses, :birthday, :date
    add_column :horses, :birth_country, :string
  end
end

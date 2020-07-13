class AddExtraInfoToCommonHorse < ActiveRecord::Migration[5.0]
  def change
    add_column :common_horses, :winning_percentage, :integer
    add_column :common_horses, :number_of_starts, :integer

    add_column :common_horses, :earnings_danish, :float
    add_column :common_horses, :earnings_norwegian, :float
    add_column :common_horses, :earnings_swedish, :float

    create_table :races do |t|
      t.references :common_horse
      t.integer :race_position
      t.string :track
      t.float :earnings
      t.date :date
    end

    add_index :races, :date
  end
end

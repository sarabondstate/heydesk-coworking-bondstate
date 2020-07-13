class CreateHorseFlags < ActiveRecord::Migration[5.0]
  def change
    create_table :horse_flags do |t|
      t.references :user
      t.references :horse

      t.timestamps
    end
  end
end

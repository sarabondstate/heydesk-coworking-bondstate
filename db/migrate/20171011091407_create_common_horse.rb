class Horse < ApplicationRecord
end
class CommonHorse < ApplicationRecord
end

class CreateCommonHorse < ActiveRecord::Migration[5.0]
  def change
    create_table :common_horses do |t|
      t.string :name, null: false
      t.string :registration_number, null: false
      t.date :birthday
      t.string :nationality, :string
      t.timestamps
    end

    add_reference :horses, :common_horse


    Horse.all.each do |horse|
      ch = CommonHorse.create(
          name: horse.name,
          registration_number: horse.registration_number,
          birthday: horse.birthday,
          nationality: horse.birth_country
      )
      horse.common_horse_id = ch.id
      horse.save
    end

    remove_columns :horses, :name, :registration_number, :birthday, :birth_country
  end
end

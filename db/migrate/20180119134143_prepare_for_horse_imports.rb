class PrepareForHorseImports < ActiveRecord::Migration[5.0]
  def change
    create_table :import_trainers do |t|
      t.integer :sportsinfo_id
      t.string :name
    end

    add_reference :users, :import_trainer

    add_column :common_horses, :sportsinfo_id, :integer
    add_index :common_horses, :sportsinfo_id

    add_column :common_horses, :father_id, :integer
    add_column :common_horses, :mother_id, :integer

    add_column :common_horses, :sportsinfo_trainer_id, :integer
  end
end

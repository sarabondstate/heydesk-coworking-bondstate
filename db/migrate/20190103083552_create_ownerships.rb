class CreateOwnerships < ActiveRecord::Migration[5.0]
  def change
    create_table :ownerships do |t|
      t.references :user, foreign_key: true
      t.references :common_horse, foreign_key: true

      t.timestamps
    end
  end
end

class CreateExternalEmployees < ActiveRecord::Migration[5.0]
  def change
    create_table :external_employees do |t|
      t.timestamps
    end
  end
end

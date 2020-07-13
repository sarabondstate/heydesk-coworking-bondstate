class AddExternalEmployeesStables < ActiveRecord::Migration[5.0]
  def self.up
    create_table :external_employees_stables, :id => false do |t|
      t.integer :external_employee_id
      t.integer :stable_id
    end
  end

  def self.down
    drop_table :external_employees_stables
  end
end

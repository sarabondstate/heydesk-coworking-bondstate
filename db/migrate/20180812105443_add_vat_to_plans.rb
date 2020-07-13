class AddVatToPlans < ActiveRecord::Migration[5.0]
  def change
    add_column :plans, :vat, :float
  end
end

class CreateCustomFieldTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :custom_field_types do |t|
      t.string :name
      t.integer :number_of_inputs, default: 1
      t.timestamps
    end
  end
end

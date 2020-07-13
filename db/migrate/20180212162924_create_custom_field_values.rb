class CreateCustomFieldValues < ActiveRecord::Migration[5.0]
  def change
    create_table :custom_field_values do |t|
      t.string :value_one
      t.string :value_two
      t.references :task, foreign_key: true
      t.references :custom_field, foreign_key: true

      t.timestamps
    end
  end
end

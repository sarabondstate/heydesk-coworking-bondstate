class AddIndexesToCustomFieldValues < ActiveRecord::Migration[5.0]
  def change
    add_index :custom_field_values, :value_one
    add_index :custom_field_values, :value_two
    add_index :custom_field_values, :created_at
    add_index :custom_field_values, :updated_at

  end
end

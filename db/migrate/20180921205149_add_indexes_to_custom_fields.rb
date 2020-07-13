class AddIndexesToCustomFields < ActiveRecord::Migration[5.0]
  def change
     add_index :custom_fields, :name
     add_index :custom_fields, :created_at
     add_index :custom_fields, :updated_at
  end
end

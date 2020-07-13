class AddLocaleToStables < ActiveRecord::Migration[5.0]
  def change
    add_column :stables, :locale, :string, default: "da"
  end
end

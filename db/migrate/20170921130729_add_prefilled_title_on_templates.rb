class AddPrefilledTitleOnTemplates < ActiveRecord::Migration[5.0]
  def change
    add_column :templates, :prefilled_title, :string, default: ''
  end
end

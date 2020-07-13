class AddActiveStateToHorse < ActiveRecord::Migration[5.0]
  def change
    add_column :horses, :active, :boolean, default: true
  end
end

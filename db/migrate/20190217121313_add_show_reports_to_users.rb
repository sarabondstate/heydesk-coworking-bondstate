class AddShowReportsToUsers < ActiveRecord::Migration[5.0]
  def change
  	add_column :users, :show_reports, :boolean
  end
end

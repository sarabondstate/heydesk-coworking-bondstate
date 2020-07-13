class AddTermsAcceptedToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :terms_accepted, :boolean, default: false
  end
end

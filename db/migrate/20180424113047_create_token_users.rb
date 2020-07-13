class CreateTokenUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :token_users do |t|
      t.references :user
      t.string :token
      t.timestamps
    end
  end
end

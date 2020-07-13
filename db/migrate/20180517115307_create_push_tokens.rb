class CreatePushTokens < ActiveRecord::Migration[5.0]
  def change
    create_table :push_tokens do |t|
      t.integer :user_id
      t.string :token

      t.timestamps
    end
    add_index :push_tokens, :token
  end
end

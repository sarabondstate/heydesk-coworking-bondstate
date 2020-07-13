class CreatePushNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :push_notifications do |t|
      t.string :title, null: false, default: ""
      t.string :message, null: false, default: ""
      t.string :token
      t.boolean :sent, null: false, default: false
      t.timestamps
    end
    add_index :push_notifications, :sent
  end
end

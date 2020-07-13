class CreateNotificationUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :notification_users do |t|
      t.references :user
      t.references :notification
      t.timestamps
    end
  end
end

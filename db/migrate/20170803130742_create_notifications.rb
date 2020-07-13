class CreateNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :notifications do |t|
      t.integer :user_id
      t.references :notifiable, polymorphic: true
      t.timestamps
    end
  end
end

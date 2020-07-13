class AddStableToNotifications < ActiveRecord::Migration[5.0]
  def change
    add_reference :notifications, :stable
  end
end

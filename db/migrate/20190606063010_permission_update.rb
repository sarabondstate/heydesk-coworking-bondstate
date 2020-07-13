include HorsesTagUpdates
class PermissionUpdate < ActiveRecord::Migration[5.0]
  def change
    ##
    # Updates the permission field of all tasks lacking proper permissions
    tasks = Task.where(permission: nil)
    tasks.each do |t|
      t.set_permissions
    end
  end
end

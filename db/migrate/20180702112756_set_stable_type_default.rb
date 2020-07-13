class SetStableTypeDefault < ActiveRecord::Migration[5.0]
  def change
    # Setting the default stable type according to Maria
    change_column_default :stables, :stable_type_id, 2
    Stable.where(stable_type_id: nil).update_all(:stable_type_id => 2)
  end
end

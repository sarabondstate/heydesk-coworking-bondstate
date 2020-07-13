class AddUserStableRelation < ActiveRecord::Migration[5.0]
  def change
    create_join_table :users, :stables do |t|
      t.index [:stable_id, :user_id]
    end

    drop_table :external_employees_stables
    remove_column :employees, :stable_id
    remove_column :trainers, :stable_id
  end
end

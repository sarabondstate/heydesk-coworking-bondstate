class CreateStableTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :stable_types do |t|
      t.string :type, :null => false
      t.timestamps
    end
  end
end

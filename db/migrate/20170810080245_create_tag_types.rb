class CreateTagTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :tag_types do |t|
      t.string :title, :null => false, :default => 'custom' 
      t.timestamps
    end
  end
end

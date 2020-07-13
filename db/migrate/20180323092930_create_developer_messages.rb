class CreateDeveloperMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :developer_messages do |t|
      t.string :message
      t.string :origin

      t.timestamps
    end
  end
end

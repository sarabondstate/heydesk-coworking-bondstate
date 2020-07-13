class AddJobStringToDeveloperMessage < ActiveRecord::Migration[5.0]
  def change
    add_column :developer_messages, :job, :string, default: ""
    add_index :developer_messages, :job
  end
end

class AddInternalNoteToTasks < ActiveRecord::Migration[5.0]
  def change
  	add_column :tasks, :internal_note, :string
  end
end

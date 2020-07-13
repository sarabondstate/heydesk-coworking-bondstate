class AddDeletedAt < ActiveRecord::Migration[5.0]
  def change
    for table in %w(users horses tasks stables)
      add_column table, :deleted_at, :datetime
      add_index table, :deleted_at
    end
  end
end

class AddIndexesToReadFeedbacks < ActiveRecord::Migration[5.0]
  def change
    add_index :read_feedbacks, :created_at
    add_index :read_feedbacks, :updated_at
  end
end

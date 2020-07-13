class AddIndexesToFeedbacks < ActiveRecord::Migration[5.0]
  def change
    add_index :feedbacks, :created_at
    add_index :feedbacks, :updated_at
  end
end

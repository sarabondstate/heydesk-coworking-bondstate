class CreateCommentUsers < ActiveRecord::Migration[5.0]
  def change
    create_join_table :comments, :users do |t|
      t.index [:comment_id, :user_id]
    end
  end
end

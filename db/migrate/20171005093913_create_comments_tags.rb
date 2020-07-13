class CreateCommentsTags < ActiveRecord::Migration[5.0]
  def change
    create_join_table :comments, :tags do |t|
      t.index [:comment_id, :tag_id]
    end

    remove_column :comments, :tag_id
  end
end

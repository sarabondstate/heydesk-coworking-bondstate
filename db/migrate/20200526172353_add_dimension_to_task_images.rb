class AddDimensionToTaskImages < ActiveRecord::Migration[5.0]
  def change
    add_column :task_images, :image_width, :string
    add_column :task_images, :image_height, :string
  end
end

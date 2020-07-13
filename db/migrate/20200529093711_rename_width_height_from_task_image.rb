class RenameWidthHeightFromTaskImage < ActiveRecord::Migration[5.0]
  def change
    remove_column :task_images, :image_width
    remove_column :task_images, :image_height
    add_column :task_images, :image_dimensions, :string
  end
end

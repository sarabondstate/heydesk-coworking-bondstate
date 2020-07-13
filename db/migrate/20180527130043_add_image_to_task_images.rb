class AddImageToTaskImages < ActiveRecord::Migration[5.0]
	def self.up
    add_attachment :task_images, :image
  end

  def self.down
    remove_attachment :task_images, :image
  end
end

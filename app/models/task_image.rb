require 'fastimage'

class TaskImage < ApplicationRecord
  belongs_to :task

  has_attached_file :image,
          :storage => :s3,
          styles: lambda { |a| a.instance.is_image? ? {:small => "x200>", :medium => "x300>", :large => "x800>"}  : { medium: { geometry: '600x450', format: 'mp4' },
              thumb: { geometry: '500x375', format: 'jpg', time: 10 }}},
          :path => lambda { |a| (a.instance.is_image? && a.instance.check_for_old_img) ? ":rails_root/public/system/:class/:attachment/:id/:basename_:style.:extension" : ":rails_root/public/system/:class/:attachment/:id/:basename.:extension" }, :processors => lambda { |a| a.is_video? ? [ :ffmpeg ] : [ :thumbnail ] },
          :default_url =>"/images/:style/missing.png"

  validates_attachment_content_type :image, content_type: %w(video/mp4 video/webm video/quicktime image/jpeg image/jpg image/png)

  process_in_background :image

  before_save :extract_dimensions
  attr_accessor :width_height, :media_original

  def image_fixed_url(style = :large)
    image.url(style)
  end

  def is_video?
    image.content_type =~ %r(video)
  end

  def is_image?
    image.content_type =~ %r(image)
  end

  def check_for_old_img
    if created_at < "Tue, 27 May 2020 10:43:52 UTC +00:00"
      false
    else
      true
    end
  end

  def url
    image_fixed_url(:large)
  end

  def thumb_url
    image_fixed_url(:thumb)
  end

  def media_type
    image_content_type.include?("video") ? "video" : "image" rescue "no attachment"
  end

  def image?
    image_content_type =~ %r{^(image|(x-)?application)/(jpeg|jpg|pjpeg|png|x-png)$}
  end

  def width_height
    if self.image_dimensions.present?
      self.image_dimensions
    else
      fetch_wid_ht
    end
  end

  def fetch_wid_ht
    FastImage.size(image_fixed_url(:large))
  end

  def media_original
    if is_video?
      image.url(:medium)
    elsif is_image?
      image.url
    end
  end

  def media_thumb
    if is_video?
      image.url(:thumb)
    end
  end

  acts_as_api
  api_accessible :basic do |template|
    template.add :id
    template.add :url, as: 'image'
    template.add :created_at
    template.add "width_height", as: :image_dimensions
    template.add "media_original", as: :media_original
    template.add "media_thumb", as: 'media_thumb_url'
    template.add :media_type, as: 'media_type'
  end

  private

  # Retrieves dimensions for image assets
  # @note Do this after resize operations to account for auto-orientation.
  def extract_dimensions
    return unless image?
    tempfile = image.queued_for_write[:original]
    unless tempfile.nil?
      geometry = Paperclip::Geometry.from_file(tempfile)
      self.image_dimensions = [geometry.width.to_i, geometry.height.to_i]
    end
  end

end

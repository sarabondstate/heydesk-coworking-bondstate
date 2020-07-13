Paperclip::Attachment.default_options[:url] = ':s3_domain_url'
Paperclip::Attachment.default_options[:path] = '/:class/:attachment/:id_partition/:style/:timestamp-:filename'
Paperclip.interpolates(:timestamp) do |attachment, style|
  attachment.instance_read(:updated_at).to_i
end
Paperclip.interpolates(:s3_bucket) do |attachement, style|
  Rails.application.config.paperclip_defaults[:s3_credentials][:bucket]
end

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  :user_name => 'a1c10a06a26e50',
  :password => 'd36e669858c13d',
  :address => 'smtp.mailtrap.io',
  :domain => 'smtp.mailtrap.io',
  :port => '2525',
  :authentication => :cram_md5
}
	# config.paperclip_defaults = {
	# 	storage: :s3,
 #    preserve_files: true,
 #    s3_protocol: :https,
	# 	s3_credentials: {
	# 		bucket: ENV.fetch('S3_BUCKET_NAME'),
	# 		access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID'),
	# 		secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY'),
	# 		s3_region: ENV.fetch('AWS_REGION'),
	# 	}
	# }

  config.action_mailer.default_url_options = { host: 'http://localhost:3000' }


  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false


  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => 'public, max-age=172800'
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  #config.action_view.raise_on_missing_translations = true
  config.i18n.fallbacks = false

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker
  Rails.application.config.fcm_key = 'AAAAPyeGOlo:APA91bFbBjwP-Wiu6Jb_NL-TPPX1sdoVC8bhr-DQGNoTG_ttNBvw5Irsr-8M_VeeC65F-maPrnheMB3u42lI81eO2McrZ-ZjKDijWS2jbu6jdXFTfp_Ug6OVTUzM6NT3CQ_C_jDPB1Le'

  # This is for finding N+1 queries
  config.after_initialize do
    Bullet.enable = true
    Bullet.bullet_logger = true
  end

end

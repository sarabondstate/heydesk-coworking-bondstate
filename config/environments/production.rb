Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  config.action_mailer.delivery_method = :smtp
  if ENV['MAILTRAP'].present?
    config.action_mailer.smtp_settings = {
        :user_name => 'f19f910779590f',
        :password => '6bb92f53cde45e',
        :address => 'smtp.mailtrap.io',
        :domain => 'smtp.mailtrap.io',
        :port => '2525',
        :authentication => :cram_md5
    }
  else
    config.action_mailer.smtp_settings = {
        address:              'smtp.gmail.com',
        port:                 587,
        domain:               'gmail.com',
        user_name:            'noreply@mosson.dk',
        password:             'MossonHoC',
        authentication:       :plain,
        enable_starttls_auto: true
    }
  end
  config.action_mailer.default_url_options = { host: (ENV['WEB_URL_IN_MAILS'] or 'http://app.mossonstable.com') }

	config.paperclip_defaults = {
		storage: :s3,
    s3_protocol: :https,
    preserve_files: true,
		s3_credentials: {
			bucket: ENV.fetch('S3_BUCKET_NAME'),
			access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID'),
			secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY'),
			s3_region: ENV.fetch('AWS_REGION'),
		}
	}

	# Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = true
  config.serve_static_assets = true

  # `config.assets.precompile` and `config.assets.version` have moved to config/initializers/assets.rb

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = 'http://assets.example.com'

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Mount Action Cable outside main process or domain
  # config.action_cable.mount_path = nil
  # config.action_cable.url = 'wss://example.com/cable'
  # config.action_cable.allowed_request_origins = [ 'http://example.com', /http:\/\/example.*/ ]

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :debug

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Use a real queuing backend for Active Job (and separate queues per environment)
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "mosson-rails_#{Rails.env}"
  config.action_mailer.perform_caching = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require 'syslog/logger'
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false
  Rails.application.config.fcm_key = 'AAAAPyeGOlo:APA91bFbBjwP-Wiu6Jb_NL-TPPX1sdoVC8bhr-DQGNoTG_ttNBvw5Irsr-8M_VeeC65F-maPrnheMB3u42lI81eO2McrZ-ZjKDijWS2jbu6jdXFTfp_Ug6OVTUzM6NT3CQ_C_jDPB1Le'

  # This is for finding N+1 queries
  if ENV['BULLET'].present?
    config.after_initialize do
      Bullet.enable = true
      Bullet.bullet_logger = true
      Bullet.slack = { webhook_url: 'https://hooks.slack.com/services/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', channel: '#mosson_bullet_results', username: 'notifier' }
      Bullet.counter_cache_enable = true
      Bullet.unused_eager_loading_enable = true
      Bullet.n_plus_one_query_enable = true



      # Just to clean up slack channel
      Bullet.add_whitelist :type => :n_plus_one_query, :class_name => "Tag", :association => :tag_type
      Bullet.add_whitelist :type => :n_plus_one_query, :class_name => "Task", :association => :type
      Bullet.add_whitelist :type => :n_plus_one_query, :class_name => "Tag", :association => :tag_type
      Bullet.add_whitelist :type => :n_plus_one_query, :class_name => "CustomField", :association => :tag_type
      Bullet.add_whitelist :type => :n_plus_one_query, :class_name => "UserStableRole", :association => :user
      Bullet.add_whitelist :type => :n_plus_one_query, :class_name => "UserStableRole", :association => :stable
      Bullet.add_whitelist :type => :n_plus_one_query, :class_name => "Feedback", :association => :notifiable
      Bullet.add_whitelist :type => :n_plus_one_query, :class_name => "Comment", :association => :comments_tagged_users

      Bullet.add_whitelist :type => :unused_eager_loading, :class_name => "PushToken", :association => :user
      Bullet.add_whitelist :type => :unused_eager_loading, :class_name => "Feedback", :association => :read_feedbacks

    end
  end


end

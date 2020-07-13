source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.2'
# Use Puma as the app server
gem 'puma', '~> 3.12'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'multi-select-rails'
gem 'bootstrap', '~> 4.0.0.beta2.1'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'rails-i18n', '~> 5.0.0' # For 5.0.x and 5.1.x


gem 'country_select'

gem 'slim-rails'
gem 'cancancan', '~> 1.10'
gem 'aws-sdk'
gem 'paperclip'
gem 'paperclip-ffmpeg'
gem "delayed_paperclip"
gem 'formtastic'
gem 'cocoon'
gem 'gmail'
gem 'wicked'
gem 'stripe', '~> 4.12.0'
gem 'will_paginate', '~> 3.1.0'

gem "lograge"
gem 'remote_syslog_logger'
gem 'logstash-event'
gem 'mono_logger'

#Firebase gems
gem 'fcm'
gem 'delayed_job_active_record'
gem "daemons"

gem 'apipie-rails'
gem 'acts_as_api'
gem 'paranoia'
gem 'whenever'
gem 'authlogic'

#Gem for cookies
gem 'cookies_eu'


gem 'rails_12factor', group: :production
gem 'pg', group: :production
# gem 'active_model_serializers', github: 'rails-api/active_model_serializers', branch: '0-9-stable'

group :development do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
	gem 'railroady'
  gem 'sqlite3'
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'capistrano-rails'
  gem 'capistrano-passenger'
  gem 'capistrano-rvm'
  gem 'capistrano-faster-assets', '~> 1.0'


  ###
  ### For review
  ###
  # for looking into indexes
  gem 'lol_dba'
  # for


end
gem 'slack-notifier'
gem 'bullet'
group :staging do
#  gem 'mysql2'
end


# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'newrelic_rpm'
gem 'fastimage'

ruby '2.4.2'

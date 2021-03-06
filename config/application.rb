require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MossonRails
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    I18n.available_locales = [:en, :da, :no, :se]

    config.i18n.default_locale = :en

    config.i18n.fallbacks = true
    config.i18n.fallbacks = [:en]

    config.eager_load = true
    config.before_configuration do 
      env_file = File.join(Rails.root, 'config', 'local_env.yml')
      YAML.load(File.open(env_file)).each do |key, value| 
        ENV[key.to_s] = value.to_s 
      end if File.exists?(env_file) 
    end
  end
end

require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module FcrepoSearch
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # Default to doing SSL certificate verification
    config.fcrepo_ssl_verify_mode = OpenSSL::SSL::VERIFY_PEER
    if ENV.has_key? 'SSL_CERT_FILE'
      config.ssl_ca_file = ENV['SSL_CERT_FILE']
    elsif File.file? '/etc/ssl/certs/ca-bundle.crt'
      # RedHat/CentOS path
      config.ssl_ca_file = '/etc/ssl/certs/ca-bundle.crt'
    elsif File.file? '/etc/ssl/certs/ca-certificates.crt'
      # Debian/Ubuntu path
      config.ssl_ca_file = '/etc/ssl/certs/ca-certificates.crt'
    end

    # CAS URL
    config.cas_url = "https://login.umd.edu/cas"
  end
end

module Blacklight::Solr
  class Repository < Blacklight::AbstractRepository
    protected
      # set the SSL CA certs path for Solr connections
      def build_connection
        conn = Faraday.new ssl: { ca_path: Rails.configuration.ssl_ca_file }
        RSolr.connect conn, connection_config
      end
  end
end

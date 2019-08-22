Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.seconds.to_i}"
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
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # FCREPO & IIIF URLs
  config.fcrepo_base_url = ENV['FCREPO_BASE_URL'] || 'https://fcrepolocal/fcrepo/rest/'
  config.iiif_base_url = ENV['IIIF_BASE_URL'] || 'https://iiiflocal/'

  # Mirador version
  config.mirador_static_version = ENV['MIRADOR_STATIC_VERSION'] || '1.1.0'

  config.audit_database = {
      dbname: ENV['AUDIT_DATABASE_NAME'] || 'fcrepo_audit',
      host: ENV['AUDIT_DATABASE_HOST'] || '192.168.40.12',
      port: ENV['AUDIT_DATABASE_PORT'] || 5432,
      user: ENV['AUDIT_DATABASE_USERNAME'] || 'archelon',
      password: ENV['AUDIT_DATABASE_PASSWORD'] || 'archelon',
  }

  config.stomp_server = {
      host: ENV['STOMP_HOST'] || '192.168.40.10',
      port: ENV['STOMP_PORT'] || 61613
  }

  config.queues = {
      export_jobs: '/queue/exportjobs',
      export_jobs_completed: '/queue/exportjobs.completed'
  }

end

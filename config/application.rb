require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Archelon
  VERSION = '1.16.3'
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # default logging to INFO, unless overridden in the environment
    config.log_level = ENV.fetch('RAILS_LOG_LEVEL', 'info')

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Workaround for Blacklight 6.23.0 due to issues caused by the changes to
    # Rails 5.2.8.1 due to CVE-2022-32224, where the following error was
    # occurring:
    #
    # Psych::DisallowedClass (Tried to load unspecified class: ActiveSupport::HashWithIndifferentAccess)
    #
    # Resources:
    # * https://discuss.rubyonrails.org/t/cve-2022-32224-possible-rce-escalation-bug-with-serialized-columns-in-active-record/81017
    # * https://github.com/projectblacklight/blacklight/issues/2768
    #
    # Specifying just "ActiveSupport::HashWithIndifferentAccess" appears to be
    # sufficient for Archelon.
    #
    # This workaround should be re-evaluated whenever Blacklight is updated to
    # determine if it is still needed.
    config.active_record.yaml_column_permitted_classes = [ActiveSupport::HashWithIndifferentAccess]
  end
end

require 'simplecov'
require 'simplecov-rcov'
SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::RcovFormatter
]
SimpleCov.start

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
require 'rails/test_help'

# Require minitest Mock functionality
require 'minitest/autorun'

require 'minitest/reporters'
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...

  # Default user for testing has Admin privileges
  DEFAULT_TEST_USER = 'test_admin'.freeze

  OmniAuth.config.test_mode = true
  OmniAuth.config.mock_auth[:cas] = {
    :provider => 'cas',
    :uid => DEFAULT_TEST_USER
  }

  def cas_login(cas_directory_id)
    OmniAuth.config.mock_auth[:cas] = {
      :provider => 'cas',
      :uid => cas_directory_id
    }
    get "/auth/cas/callback"
  end

  def mock_cas_login(cas_directory_id)
    OmniAuth.config.mock_auth[:cas] = {
      :provider => 'cas',
      :uid => cas_directory_id
    }
    request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:cas]
    session[:cas_user] = cas_directory_id
  end

  # Runs the contents of a block using the given user as the current_user.
  def run_as_user(user)
    mock_cas_login(user.cas_directory_id)

    begin
      yield
    rescue Exception => e # rubocop:disable Lint/RescueException
      raise e
    ensure
      # Restore fake user
      mock_cas_login(DEFAULT_TEST_USER)
    end
  end

  # Fix failing test
  if RUBY_VERSION>='2.6.0'
    if Rails.version < '5'
      class ActionController::TestResponse < ActionDispatch::TestResponse
        def recycle!
          # hack to avoid MonitorMixin double-initialize error:
          @mon_mutex_owner_object_id = nil
          @mon_mutex = nil
          initialize
        end
      end
    else
      puts "Monkeypatch for ActionController::TestResponse no longer needed"
    end
  end
end

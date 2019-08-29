# frozen_string_literal: true

require 'simplecov'
require 'simplecov-rcov'
SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::RcovFormatter
]
SimpleCov.start

require_relative '../config/environment'
require 'rails/test_help'
require 'minitest/reporters'
Minitest::Reporters.use!

# Require minitest Mock functionality
require 'minitest/autorun'
require 'rspec/mocks/minitest_integration'

# This is a workaround for https://github.com/kern/minitest-reporters/issues/230
# This workaround can be removed once we upgrade to Rails v5.1.6
Minitest.load_plugins
Minitest.extensions.delete('rails')
Minitest.extensions.unshift('rails')
# End of workaround

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...

  # Default user for testing has Admin privileges
  DEFAULT_TEST_USER = 'test_admin'

  OmniAuth.config.test_mode = true
  OmniAuth.config.mock_auth[:cas] = {
    provider: 'cas',
    uid: DEFAULT_TEST_USER
  }

  def cas_login(cas_directory_id)
    OmniAuth.config.mock_auth[:cas] = {
      provider: 'cas',
      uid: cas_directory_id
    }

    get '/auth/cas/callback'
  end

  def mock_cas_login(cas_directory_id)
    OmniAuth.config.mock_auth[:cas] = {
      provider: 'cas',
      uid: cas_directory_id
    }
    request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:cas]
    session[:cas_user] = cas_directory_id
  end

  def mock_cas_login_for_integration_tests(cas_directory_id)
    allow(CasUser)
      .to receive(:find_or_create_from_auth_hash)
      .with(anything)
      .and_return(CasUser.find_by(cas_directory_id: cas_directory_id))

    cas_login(cas_directory_id)
  end

  # Runs the contents of a block using the given user as the current_user.
  def impersonate_as_user(user) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    current_admin_user = CasUser.find_by(cas_directory_id: session[:cas_user])
    session[:admin_id] = current_admin_user.id
    session[:cas_user] = user.cas_directory_id

    begin
      yield
    rescue Exception => e # rubocop:disable Lint/RescueException
      raise e
    ensure
      # Restore fake user
      session[:cas_user] = CasUser.find(session[:admin_id]).cas_directory_id
      session.delete(:admin_id)
    end
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
end

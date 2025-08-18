# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

# UMD Customization
require 'simplecov'
require 'simplecov-rcov'
SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::RcovFormatter
]
SimpleCov.start
# End UMD Customization

require_relative '../config/environment'
require 'rails/test_help'

# UMD Customization
require 'minitest/reporters'
# only use if we are not running inside the JetBrains RubyMine IDE
Minitest::Reporters.use! unless ENV['RM_INFO']

# Require minitest Mock functionality
require 'minitest/autorun'
require 'rspec/mocks/minitest_integration'
require 'webmock/minitest'
# End UMD Customization

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...

    # UMD Customization
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
      CasAuthentication.sign_in(cas_directory_id, session, cookies)
    end

    def mock_cas_login_for_integration_tests(cas_directory_id)
      allow(CasUser)
        .to receive(:find_or_create_from_auth_hash)
        .with(anything)
        .and_return(CasUser.find_by(cas_directory_id: cas_directory_id))

      cas_login(cas_directory_id)
    end

    def mock_cas_logout
      request.env.delete('omniauth.auth')
      CasAuthentication.sign_out(session, cookies)
    end

    # Runs the contents of a block using the given user as the current_user.
    def impersonate_as_user(user) # rubocop:disable Metrics/AbcSize
      current_admin_user = CasUser.find_by(cas_directory_id: session[:cas_user])
      session[:admin_id] = current_admin_user.id
      # session[:cas_user] = user.cas_directory_id
      CasAuthentication.sign_in(user.cas_directory_id, session, cookies)

      begin
        yield
      ensure
        # Restore fake user
        CasAuthentication.sign_in(CasUser.find(session[:admin_id]).cas_directory_id, session, cookies)
        # session[:cas_user] = CasUser.find(session[:admin_id]).cas_directory_id
        session.delete(:admin_id)
      end
    end

    # Runs the contents of a block using the given user as the current_user.
    def run_as_user(user)
      mock_cas_login(user.cas_directory_id)

      begin
        yield
      ensure
        # Restore fake user
        mock_cas_login(DEFAULT_TEST_USER)
      end
    end

    # Replaces Stomp::Connection with a stub.
    def mock_stomp_connection(error: :none) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      connection_double = double('stomp_connection')
      allow(connection_double).to receive(:disconnect)

      case error
      when :none
        allow(connection_double).to receive(:publish)
      when :transient
        # raise an error on the first two calls to publish, to simulate a
        # short-term, transient network failure
        call_count = 0
        allow(connection_double).to receive(:publish) do
          call_count += 1
          call_count < 3 ? raise(RuntimeError) : true
        end
      when :permanent
        # always fail to publish, to simulate a completely dead connection
        allow(connection_double).to receive(:publish).and_raise(RuntimeError)
      end

      rspec_stub_const(
        'Stomp::Connection', double(new: connection_double)
      )
    end

    # Explicit call to the RSpec "stub_const" method.
    # This is needed because the "ActiveSupport::Testing::ConstantStubbing"
    # module also includes a "stub_const" method.
    #
    # Using the method makes it explicit which method is being called.
    def rspec_stub_const(constant_name, value, options = {})
      # Using the "Class.new.extend(RSpec::Mocks::ExampleMethods)"
      # to ensure that the "stub_const" method from the module is called,
      # instead of the "stub_const" method from the
      # "ActiveSupport::Testing::ConstantStubbing" module.
      # Not sure if this is really the best way to
      # do this -- taken from https://stackoverflow.com/a/1411061
      Class.new.extend(RSpec::Mocks::ExampleMethods).stub_const(
        constant_name, value, options
      )
    end

    # End UMD Customization
  end
end

# UMD Customization

# Stub response for RepositoryCollections Solr requests from fixture file
def stub_repository_collections_solr_response(fixture_filename)
  file = file_fixture(fixture_filename).read
  data_hash = JSON.parse(file)

  response = Blacklight::Solr::Response.new(data_hash, nil)
  Blacklight::Solr::Repository.any_instance.stub(:search).and_return(response)
end

# Allows a constant defined in config/initializers to be be overridden for
# a single test, and then restored
def with_constant(constant_name, value)
  old_value = Rails.const_get(constant_name)
  silence_warnings do # Silence warning about redefining constant
    Object.const_set(constant_name, value)
  end

  yield

  silence_warnings do
    Object.const_set(constant_name, old_value)
  end
end

# mock the environment during testing
# https://stackoverflow.com/a/76036999
def mock_env(partial_env_hash)
  old = ENV.to_hash
  ENV.update partial_env_hash
  begin
    yield
  ensure
    ENV.replace old
  end
end

# End UMD Customization

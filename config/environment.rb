# Load the Rails application.
require File.expand_path('application', __dir__)

# enable detailed CAS logging
cas_logger = CASClient::Logger.new(::Rails.root.to_s + '/log/cas.log')
cas_logger.level = Logger::DEBUG

CASClient::Frameworks::Rails::Filter.configure(
  cas_base_url: 'https://login.umd.edu/cas',
  logger: cas_logger
)

# Initialize the Rails application.
Rails.application.initialize!

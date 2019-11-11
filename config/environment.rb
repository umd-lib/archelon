# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

# Set default email from address (archelon@<HOSTNAME>)
ActionMailer::Base.default from: 'archelon@' + `hostname | tr -d '\n'`
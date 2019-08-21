# frozen_string_literal: true

require './lib/utils/stomp_client'

# Only start Stomp connection when Rails server is actually running
STOMP_CLIENT = StompClient.instance if defined?(Rails::Server)

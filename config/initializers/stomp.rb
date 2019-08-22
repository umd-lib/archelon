# frozen_string_literal: true

# Only start Stomp connection when Rails server is actually running
STOMP_CLIENT = StompClient.instance if defined?(Rails::Server)

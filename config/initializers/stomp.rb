# Load the configuration
STOMP_CONFIG = Archelon::Application.config_for :stomp

# Only start Stomp connection when Rails server is actually running
STOMP_CLIENT = StompClient.instance if defined?(Rails::Server) || Rails.env.production?

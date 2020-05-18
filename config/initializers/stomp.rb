# STOMP server and destinations
STOMP_CONFIG = Archelon::Application.config_for :stomp

# Convenient shorthand for passing host and port to Stomp::Client and Stomp::Connection
STOMP_SERVER = { host: STOMP_CONFIG['host'], port: STOMP_CONFIG['port'] }

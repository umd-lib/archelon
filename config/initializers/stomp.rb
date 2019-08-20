# Only start Stomp connection when Rails server is actually running
if defined?(Rails::Server)
  STOMP_CLIENT = Stomp::Client.new(hosts: [Rails.configuration.stomp_server])
end

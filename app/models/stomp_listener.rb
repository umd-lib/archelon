# frozen_string_literal: true

# STOMP client for long-running subscriptions to queues and topics
class StompListener
  def connect
    server = "#{STOMP_SERVER[:host]}:#{STOMP_SERVER[:port]}"
    puts "Connecting to STOMP server at #{server}"
    begin
      @stomp_client = Stomp::Client.new(hosts: [STOMP_SERVER], reliable: true)
      puts "Connected to STOMP server at #{server}"
      self
    rescue Stomp::Error::MaxReconnectAttempts
      puts "Unable to connect to STOMP message broker at #{server}"
      return
    end
  end

  def subscribe(destination, &block)
    destination = STOMP_CONFIG['destinations'][destination.to_s]
    puts "Subscribing to #{destination}"
    @stomp_client.subscribe destination, &block
    puts "Subscribed to #{destination}"
  end
end

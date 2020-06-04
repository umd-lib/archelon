# frozen_string_literal: true

namespace :stomp do
  desc 'Start a STOMP listener'
  task listen: :environment do
    # immediately flush stdout, since in production situations
    # we will be writing to a logfile
    $stdout.sync = true

    listener = StompListener.new.connect || exit(1)

    listener.subscribe(:jobs_completed, 'client-individual') do |stomp_msg|
      message = PlastronMessage.new(stomp_msg)
      puts "Updating job status for #{message.job_id}"
      message.find_job.update_status(message)
      listener.send_ack(message)
    rescue StandardError => e
      puts "An error occurred processing stomp_msg: #{stomp_msg}"
      listener.send_nack(message)
      puts e, e.backtrace
    end

    listener.subscribe(:job_status) do |stomp_msg|
      message = PlastronMessage.new(stomp_msg)
      puts "Updating job progress for #{message.job_id}"
      message.find_job.update_progress(message)
    end

    begin
      loop { sleep(0.1) }
    rescue Interrupt
      listener.stop
    end
  end
end

# STOMP client for long-running subscriptions to queues and topics
class StompListener
  # Connects to the STOMP server
  def connect # rubocop:disable Metrics/MethodLength
    server = "#{STOMP_SERVER[:host]}:#{STOMP_SERVER[:port]}"
    puts "Connecting to STOMP server at #{server}"
    begin
      connect_headers = { 'accept-version': '1.2', 'host': STOMP_SERVER[:host] }
      @client = Stomp::Client.new(hosts: [STOMP_SERVER], reliable: true, connect_headers: connect_headers)
      puts "Connected to STOMP server at #{server}"
      self
    rescue Stomp::Error::MaxReconnectAttempts
      puts "Unable to connect to STOMP message broker at #{server}"
      return
    end
  end

  # Subscribe to a given destination
  #
  # See https://stomp.github.io/stomp-specification-1.2.html#SUBSCRIBE_ack_Header
  # for information about acknowledgement modes.
  def subscribe(destination, acknowledgement_mode = 'auto', &block)
    destination = STOMP_CONFIG['destinations'][destination.to_s]
    puts "Subscribing to #{destination} with acknowledgement_mode=#{acknowledgement_mode}"
    @client.subscribe destination, ack: acknowledgement_mode, &block
    puts "Subscribed to #{destination}"
  end

  # Send an "ACK" (acknowledgement) for the given message. Not needed for "auto"
  # subscriptions.
  def send_ack(message)
    @client.ack(message)
  end

  # Send an "NACK" (negative acknowledgement) for the given message. Not needed
  # for "auto" subscriptions
  def send_nack(message)
    @client.nack(message)
  end

  # Stops and closes the connection to the STOMP server.
  def stop
    server = "#{STOMP_SERVER[:host]}:#{STOMP_SERVER[:port]}"
    puts "Closing connection to #{server}"
    @client.close
    puts "Closed connection to #{server}"
  end
end

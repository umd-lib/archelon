# frozen_string_literal: true

namespace :stomp do
  desc 'Start a STOMP listener'
  task listen: :environment do
    listener = StompListener.new.connect || exit(1)

    listener.subscribe(:jobs_completed) do |stomp_msg|
      message = PlastronMessage.new(stomp_msg)
      puts "Updating job status for #{message.job_id}"
      message.find_job.update_status(message)
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
  def connect
    server = "#{STOMP_SERVER[:host]}:#{STOMP_SERVER[:port]}"
    puts "Connecting to STOMP server at #{server}"
    begin
      @client = Stomp::Client.new(hosts: [STOMP_SERVER], reliable: true)
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
    @client.subscribe destination, &block
    puts "Subscribed to #{destination}"
  end

  def stop
    server = "#{STOMP_SERVER[:host]}:#{STOMP_SERVER[:port]}"
    puts "Closing connection to #{server}"
    @client.close
    puts "Closed connection to #{server}"
  end
end

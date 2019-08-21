# frozen_string_literal: true

class MockStompClient < StompClient
  def initialize
    puts '*** initialize'
  end

  def self.instance
    @@instance ||= new # rubocop:disable Style/ClassVars
  end

  def publish(_destination, _message, _headers = {})
    puts '*** publish'
  end

  def update_export_job(_stomp_msg)
    puts '*** update_export_job'
  end
end

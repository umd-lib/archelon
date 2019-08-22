# frozen_string_literal: true

require 'test_helper'

class MockStompClient < StompClient
  def initialize
    # Skip initialization
  end
end

class StompClientTest < Minitest::Test
  def setup
  end

  def test_update_export_job_when_message_received
    mock = MockStompClient.instance
    job = ExportJob.new(name: 'test job')
    job.save
    message = create_message(job.id)
    mock.update_export_job(message)
    job.reload
    assert_equal 'Ready', job.status
  end

  def test_update_export_job_when_error_received
    mock = MockStompClient.instance
    job = ExportJob.new(name: 'test job')
    job.save
    message = create_message(job.id)
    mock.update_export_job(message)
    job.reload
    assert_equal 'Ready', job.status
  end

  def create_message(job_id)
    message = Stomp::Message.new('')
    headers = {}
    headers['ArchelonExportJobId'] = job_id.to_s
    headers['ArchelonExportJobStatus'] = 'Ready'
    message.command = 'MESSAGE'
    message.headers = headers
    message
  end
end

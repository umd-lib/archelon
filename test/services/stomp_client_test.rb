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
    cas_user = CasUser.first
    op = PlastronOperation.first
    job = ExportJob.new(name: 'test job', cas_user: cas_user, plastron_operation: op)
    job.save!
    message = create_message(job.id)
    mock.update_export_job_status(message)
    job.reload
    assert job.plastron_operation.done?
  end

  def test_update_export_job_when_error_received
    mock = MockStompClient.instance
    cas_user = CasUser.first
    op = PlastronOperation.first
    job = ExportJob.new(name: 'test job', cas_user: cas_user, plastron_operation: op)
    job.save!
    message = create_message(job.id)
    mock.update_export_job_status(message)
    job.reload
    assert job.plastron_operation.done?
  end

  def create_message(job_id)
    message = Stomp::Message.new('')
    headers = {}
    headers['PlastronJobId'] = "http://example.com/job/#{job_id}"
    headers['PlastronJobStatus'] = 'Done'
    message.command = 'MESSAGE'
    message.headers = headers
    message.body = JSON.generate(download_uri: 'http://example.com/foo')
    message
  end
end

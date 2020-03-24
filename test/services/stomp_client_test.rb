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

  def test_update_job_when_done
    mock = MockStompClient.instance
    cas_user = CasUser.first
    op = PlastronOperation.first
    job = ExportJob.new(name: 'test job', cas_user: cas_user, plastron_operation: op)
    job.save!
    message = create_message(job.id, 'Done')
    mock.update_job_status(message)
    job.reload
    assert job.plastron_operation.done?
  end

  def test_update_job_on_error
    mock = MockStompClient.instance
    cas_user = CasUser.first
    op = PlastronOperation.first
    job = ExportJob.new(name: 'test job', cas_user: cas_user, plastron_operation: op)
    job.save!
    message = create_message(job.id, 'Error')
    mock.update_job_status(message)
    job.reload
    assert job.plastron_operation.error?
  end

  def test_update_job_when_failed
    mock = MockStompClient.instance
    cas_user = CasUser.first
    op = PlastronOperation.first
    job = ExportJob.new(name: 'test job', cas_user: cas_user, plastron_operation: op)
    job.save!
    message = create_message(job.id, 'Failed')
    mock.update_job_status(message)
    job.reload
    assert job.plastron_operation.failed?
  end

  def create_message(job_id, status)
    Stomp::Message.new('').tap do |message|
      message.command = 'MESSAGE'
      message.headers = {
        PlastronJobId: "http://localhost:3000/export_jobs/#{job_id}",
        PlastronJobStatus: status
      }
      message.body = JSON.generate(download_uri: 'http://example.com/foo')
    end
  end
end

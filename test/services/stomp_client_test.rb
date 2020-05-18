# frozen_string_literal: true

require 'test_helper'

class StompClientTest < Minitest::Test
  def setup
  end

  def test_update_job_when_done
    cas_user = CasUser.first
    job = ExportJob.new(name: 'test job', cas_user: cas_user)
    job.save!
    message = create_message(job.id, 'Done')
    message.find_job.update_status(message)
    job.reload
    assert job.plastron_status_done?
  end

  def test_update_job_on_error
    cas_user = CasUser.first
    job = ExportJob.new(name: 'test job', cas_user: cas_user)
    job.save!
    message = create_message(job.id, 'Error')
    message.find_job.update_status(message)
    job.reload
    assert job.plastron_status_error?
  end

  def test_update_job_when_failed
    cas_user = CasUser.first
    job = ExportJob.new(name: 'test job', cas_user: cas_user)
    job.save!
    message = create_message(job.id, 'Failed')
    message.find_job.update_status(message)
    job.reload
    assert job.plastron_status_failed?
  end

  def create_message(job_id, status)
    PlastronMessage.new(
      Stomp::Message.new('').tap do |message|
        message.command = 'MESSAGE'
        message.headers = {
          PlastronJobId: "http://localhost:3000/export_jobs/#{job_id}",
          PlastronJobStatus: status
        }
        message.body = JSON.generate(download_uri: 'http://example.com/foo')
      end
    )
  end
end

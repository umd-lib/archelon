# frozen_string_literal: true

require 'test_helper'

class StompClientTest < Minitest::Test
  def setup
  end

  def test_update_job_when_done
    cas_user = CasUser.first
    job = ExportJob.new(name: 'test job', cas_user: cas_user)
    job.save!
    message = create_message(job.id, :export_complete)
    message.find_job.update_status(message)
    job.reload
    assert job.export_complete?
  end

  def test_update_job_on_error
    cas_user = CasUser.first
    job = ExportJob.new(name: 'test job', cas_user: cas_user)
    job.save!
    message = create_message(job.id, :export_error)
    message.find_job.update_status(message)
    job.reload
    assert job.export_error?
  end

  def create_message(job_id, state)
    PlastronMessage.new(
      Stomp::Message.new('').tap do |message|
        message.command = 'MESSAGE'
        message.headers = {
          PlastronJobId: "http://localhost:3000/export_jobs/#{job_id}",
          PlastronJobState: state.to_s
        }
        message.body = JSON.generate(download_uri: 'http://example.com/foo')
      end
    )
  end
end

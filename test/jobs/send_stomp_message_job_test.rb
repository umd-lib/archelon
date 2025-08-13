# frozen_string_literal: true

require 'test_helper'

class SendStompMessageJobTest < ActiveJob::TestCase
  setup do
    # force all enqueued_at jobs to run immediately
    ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs = true

    @queue_name = '/queue/plastron.jobs'
  end

  def import_request
    request = ImportJobRequest.first
    request.import_job.metadata_file.attach(
      io: File.open(Rails.root.join('test/fixtures/files/valid_import.csv')),
      filename: 'valid_import.csv',
      content_type: 'text/csv'
    )
    request
  end

  test 'import job submitted to active connection succeeds' do
    mock_stomp_connection

    assert import_request.import_job.validate_pending?
    SendStompMessageJob.perform_now(@queue_name, import_request)
    assert import_request.reload.import_job.validate_in_progress?
  end

  test 'import job submitted to broken connection fails' do
    mock_stomp_connection error: :permanent

    assert import_request.import_job.validate_pending?
    SendStompMessageJob.perform_now(@queue_name, import_request)
    assert import_request.reload.import_job.validate_error?
  end

  test 'import job submitted to connection with transient error succeeds' do
    mock_stomp_connection error: :transient

    assert import_request.import_job.validate_pending?
    SendStompMessageJob.perform_now(@queue_name, import_request)
    assert import_request.reload.import_job.validate_in_progress?
  end

  test 'export job submitted to active connection succeeds' do
    mock_stomp_connection

    request = ExportJobRequest.first
    assert request.export_job.pending?
    SendStompMessageJob.perform_now(@queue_name, request)
    assert request.reload.export_job.in_progress?
  end

  test 'export job submitted to broken connection fails' do
    mock_stomp_connection error: :permanent

    request = ExportJobRequest.first
    assert request.export_job.pending?
    SendStompMessageJob.perform_now(@queue_name, request)
    assert request.reload.export_job.export_error?
  end

  test 'export job submitted to connection with transient error succeeds' do
    mock_stomp_connection error: :transient

    request = ExportJobRequest.first
    assert request.export_job.pending?
    SendStompMessageJob.perform_now(@queue_name, request)
    assert request.reload.export_job.in_progress?
  end
end

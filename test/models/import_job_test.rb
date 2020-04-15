# frozen_string_literal: true

require 'test_helper'

class ImportJobTest < ActiveSupport::TestCase
  test 'status reflects current status of job' do
    import_job = import_jobs(:one)

    json_successful_response =
      '{ "count": { "total": 1, "updated": 0, "unchanged": 0, "valid": 1, "invalid": 0, "errors": 0 } }'
    json_failed_response =
      '{ "count": { "total": 2, "updated": 0, "unchanged": 0, "valid": 1, "invalid": 1, "errors": "0" }, "validation": [] }'

    tests = [
      { import_job_stage: :validate, plastron_status: :plastron_status_pending, response: nil, expected: :validate_pending },
      { import_job_stage: :validate, plastron_status: :plastron_status_error, response: nil, expected: :error },
      { import_job_stage: :validate, plastron_status: :plastron_status_done, response: json_successful_response, expected: :validate_success },
      { import_job_stage: :validate, plastron_status: :plastron_status_done, response: json_failed_response, expected: :validate_failed },
      { import_job_stage: :validate, plastron_status: :plastron_status_in_progress, response: nil, expected: :in_progress },
      { import_job_stage: :import, plastron_status: :plastron_status_pending, response: nil, expected: :import_pending },
      { import_job_stage: :import, plastron_status: :plastron_status_error, response: nil, expected: :error },
      { import_job_stage: :import, plastron_status: :plastron_status_done, response: json_successful_response, expected: :import_success },
      { import_job_stage: :import, plastron_status: :plastron_status_done, response: json_failed_response, expected: :import_failed },
      { import_job_stage: :import, plastron_status: :plastron_status_in_progress, response: nil, expected: :in_progress }
    ]
    tests.each do |test|
      import_job.stage = test[:import_job_stage]
      import_job.plastron_status = test[:plastron_status]
      import_job.last_response = test[:response]
      import_job.save!
      expected = test[:expected]
      assert_equal(expected, import_job.status, "Failed for (#{import_job.stage}, #{import_job.plastron_status})")
    end
  end

  test 'workflow_action provides the next workflow step' do
    import_job = import_jobs(:one)

    tests = [
      { status: :validate_pending, expected_workflow_action: nil },
      { status: :error, expected_workflow_action: nil },
      { status: :validate_success, expected_workflow_action: :import },
      { status: :validate_failed, expected_workflow_action: :resubmit },
      { status: :in_progress, expected_workflow_action: nil },
      { status: :import_pending, expected_workflow_action: nil },
      { status: :import_success, expected_workflow_action: nil },
      { status: :import_failed, expected_workflow_action: nil }
    ]

    tests.each do |test|
      import_job.stub :status, test[:status] do
        expected = test[:expected_workflow_action]
        if expected.nil?
          assert_nil(import_job.workflow_action, "Failed for (#{import_job.status})")
        else
          assert_equal(expected, import_job.workflow_action, "Failed for (#{import_job.status})")
        end
      end
    end
  end
end

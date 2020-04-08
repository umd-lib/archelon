# frozen_string_literal: true

require 'test_helper'

class ImportJobTest < ActiveSupport::TestCase
  test 'PlastronOperation is deleted when ImportJob is deleted' do
    import_job = import_jobs(:one)
    assert_not_nil(import_job.plastron_operation)

    assert_difference('ImportJob.count', -1) do
      assert_difference('PlastronOperation.count', -1) do
        import_job.destroy!
      end
    end
  end

  test 'ImportJob is not deleted when PlastronOperation is deleted' do
    # Not sure if this is really the desired behavior. Ordinarily would
    # expect a one-to-one relationship between ImportJob and it's
    # associated PlastronOperation, so that deleting one deletes the other.
    # Suspect it was done this way so that PlastronOperation would not
    # need to deal with polymorphism between ExportJob/ImportJob in
    # a "has_one" relationship.
    plastron_op = plastron_operations(:import_op1)

    assert_no_difference('ImportJob.count') do
      assert_difference('PlastronOperation.count', -1) do
        plastron_op.destroy!
      end
    end
  end

  test 'status reflects current status of job' do # rubocop:disable Metrics/BlockLength
    import_job = import_jobs(:one)
    plastron_op = plastron_operations(:op1)
    import_job.plastron_operation = plastron_op

    json_successful_response =
      '{ "count": { "total": 1, "updated": 0, "unchanged": 0, "valid": 1, "invalid": 0, "errors": 0 } }'
    json_failed_response =
      '{ "count": { "total": 2, "updated": 0, "unchanged": 0, "valid": 1, "invalid": 1, "errors": "0" }, "validation": [] }'

    tests = [
      { import_job_stage: :validate, plastron_status: :pending, response: nil, expected: :validate_pending },
      { import_job_stage: :validate, plastron_status: :error, response: nil, expected: :error },
      { import_job_stage: :validate, plastron_status: :done, response: json_successful_response, expected: :validate_success },
      { import_job_stage: :validate, plastron_status: :done, response: json_failed_response, expected: :validate_failed },
      { import_job_stage: :validate, plastron_status: :in_progress, response: nil, expected: :in_progress },
      { import_job_stage: :import, plastron_status: :pending, response: nil, expected: :import_pending },
      { import_job_stage: :import, plastron_status: :error, response: nil, expected: :error },
      { import_job_stage: :import, plastron_status: :done, response: json_successful_response, expected: :import_success },
      { import_job_stage: :import, plastron_status: :done, response: json_failed_response, expected: :import_failed },
      { import_job_stage: :import, plastron_status: :in_progress, response: nil, expected: :in_progress }
    ]
    tests.each do |test|
      import_job.stage = test[:import_job_stage]
      plastron_op.status = test[:plastron_status]
      plastron_op.response_message = test[:response]
      expected = test[:expected]
      assert_equal(expected, import_job.status, "Failed for (#{import_job.stage}, #{plastron_op.status})")
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

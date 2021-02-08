# frozen_string_literal: true

require 'test_helper'

class ImportJobTest < ActiveSupport::TestCase
  test 'status reflects current status of job' do # rubocop:disable Metrics/BlockLength
    import_job = import_jobs(:one)

    json_successful_response =
      '{ "count": { "total": 1, "updated": 0, "unchanged": 0, "valid": 1, "invalid": 0, "errors": 0 } }'
    json_failed_response =
      '{ "count": { "total": 2, "updated": 0, "unchanged": 0, "valid": 1, "invalid": 1, "errors": "0" }, "validation": [] }'

    tests = [
      { import_job_stage: :validate, plastron_status: :plastron_status_pending, response: nil, expected: :validate_pending },
      { import_job_stage: :validate, plastron_status: :plastron_status_error, response: nil, expected: :validate_error },
      { import_job_stage: :validate, plastron_status: :plastron_status_done, response: json_successful_response, expected: :validate_success },
      { import_job_stage: :validate, plastron_status: :plastron_status_done, response: json_failed_response, expected: :validate_failed },
      { import_job_stage: :validate, plastron_status: :plastron_status_in_progress, response: nil, expected: :in_progress },
      { import_job_stage: :import, plastron_status: :plastron_status_pending, response: nil, expected: :import_pending },
      { import_job_stage: :import, plastron_status: :plastron_status_error, response: nil, expected: :import_error },
      { import_job_stage: :import, plastron_status: :plastron_status_done, response: json_successful_response, expected: :import_success },
      { import_job_stage: :import, plastron_status: :plastron_status_done, response: json_failed_response, expected: :import_failed },
      { import_job_stage: :import, plastron_status: :plastron_status_in_progress, response: nil, expected: :in_progress }
    ]
    tests.each do |test|
      import_job.stage = test[:import_job_stage]
      import_job.plastron_status = test[:plastron_status]
      import_job.last_response_headers = '{}' # Simple valid header
      import_job.last_response_body = test[:response]
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

  test 'binaries? indicates whether the import job has a binary zip file or remote server' do
    import_job = import_jobs(:import_job_without_binaries)
    assert_equal false, import_job.binaries?

    import_job = import_jobs(:import_job_with_binaries_location)
    assert import_job.binaries?
  end

  test 'collection_relpath returns the proper relative path' do
    test_base_urls = [
      # Test for base urls with and without final slash
      'http://example.com/rest',
      'http://example.com/rest/'
    ]

    test_collections = [
      # [Collection, Expected relative path]
      ["http://example.com/rest#{ImportJob::FLAT_LAYOUT_RELPATH}", ImportJob::FLAT_LAYOUT_RELPATH],
      ["http://example.com/rest#{ImportJob::FLAT_LAYOUT_RELPATH}/51/a4/54/a8/51a454a8-7ad0-45dd-ba2b-85632fe1b618", ImportJob::FLAT_LAYOUT_RELPATH],
      ['http://example.com/rest/dc/2021/2', '/dc/2021/2']
    ]

    test_base_urls.each do |base_url|
      with_constant('FCREPO_BASE_URL', base_url) do
        test_collections.each do |collection, expected_relpath|
          import_job = ImportJob.new
          import_job.collection = collection
          assert_equal expected_relpath, import_job.collection_relpath, "Using base_url: '#{base_url}'"
        end
      end
    end
  end

  test 'structure_type returns "hierarchical" for hierarchical collections' do
    with_constant('FCREPO_BASE_URL', 'http://example.com/rest') do
      import_job = ImportJob.new
      import_job.collection = 'http://example.com/rest/dc/2021/2'
      assert_equal :hierarchical, import_job.collection_structure
    end
  end

  test 'structure_type returns "flat" for flat collections' do
    with_constant('FCREPO_BASE_URL', 'http://example.com/rest/') do
      import_job = ImportJob.new
      import_job.collection = 'http://example.com/rest/pcdm'
      assert_equal :flat, import_job.collection_structure
    end
  end

  test 'structure_type returns "flat" for flat collections when FCREPO_BASE_URL does not include final slash' do
    with_constant('FCREPO_BASE_URL', 'http://example.com/rest') do
      import_job = ImportJob.new
      import_job.collection = 'http://example.com/rest/pcdm'
      assert_equal :flat, import_job.collection_structure
    end
  end
end

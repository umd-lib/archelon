# frozen_string_literal: true

require 'test_helper'

class ImportJobInfoTest < ActiveSupport::TestCase
  def setup
  end

  test 'On error, ImportJobInfo indicates error occurred and has sensible defaults' do
    json_rest_result = JsonRestResult.create_error_result('404 Not Found')
    import_job_info = ImportJobInfo.new(json_rest_result)
    assert(import_job_info.error_occurred?)
    assert_equal('404 Not Found', import_job_info.error_message)
    assert_equal([], import_job_info.completed)
    assert_equal(0, import_job_info.total)
  end

  test 'On success, ImportJobInfo contains relevant info' do
    json_fixture_file = 'services/import_job/plastron_job_detail_response.json'
    json_response = file_fixture(json_fixture_file).read

    json_rest_result = JsonRestResult.create_from_json(json_response)
    import_job_info = ImportJobInfo.new(json_rest_result)

    assert_equal(2, import_job_info.completed.count)
    assert_equal(4, import_job_info.total)
  end
end

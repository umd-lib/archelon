# frozen_string_literal: true

require 'test_helper'

class ImportJobResponseTest < Minitest::Test
  def setup
  end

  def test_nil_headers_and_body
    headers_json = nil
    body_json = nil
    import_job_response = ImportJobResponse.new(headers_json, body_json)
    assert_equal(false, import_job_response.valid?)
    assert_equal(true, import_job_response.server_error?)
    assert_equal(:invalid_response_from_server, import_job_response.server_error)
    assert_equal('', import_job_response.headers_pretty_print)
    assert_equal('', import_job_response.body_pretty_print)
  end

  def test_empty_headers_and_body
    headers_json = ''
    body_json = ''
    import_job_response = ImportJobResponse.new(headers_json, body_json)
    assert_equal(false, import_job_response.valid?)
    assert_equal(true, import_job_response.server_error?)
    assert_equal(:invalid_response_from_server, import_job_response.server_error)
    assert_equal('', import_job_response.headers_pretty_print)
    assert_equal('', import_job_response.body_pretty_print)
  end

  def test_nil_headers_and_valid_body
    headers_json = nil
    body_json = '{ "count": { "total": 2, "updated": 0, "unchanged": 0, "valid": 1, "invalid": 1, "errors": "0" }, "validation": [] }'
    import_job_response = ImportJobResponse.new(headers_json, body_json)
    assert_equal(false, import_job_response.valid?)
    assert_equal(true, import_job_response.server_error?)
    assert_equal(:invalid_response_from_server, import_job_response.server_error)
    assert_equal('', import_job_response.headers_pretty_print)
    assert_equal('', import_job_response.body_pretty_print)
  end

  def test_empty_headers_and_valid_body
    headers_json = ''
    body_json = '{ "count": { "total": 2, "updated": 0, "unchanged": 0, "valid": 1, "invalid": 1, "errors": "0" }, "validation": [] }'
    import_job_response = ImportJobResponse.new(headers_json, body_json)
    assert_equal(false, import_job_response.valid?)
    assert_equal(true, import_job_response.server_error?)
    assert_equal(:invalid_response_from_server, import_job_response.server_error)
    assert_equal('', import_job_response.headers_pretty_print)
    assert_equal('', import_job_response.body_pretty_print)
  end

  def test_invalid_headers_and_valid_body
    headers_json = 'INVALID_JSON'
    body_json = '{ "count": { "total": 2, "updated": 0, "unchanged": 0, "valid": 1, "invalid": 1, "errors": "0" }, "validation": [] }'
    import_job_response = ImportJobResponse.new(headers_json, body_json)
    assert_equal(false, import_job_response.valid?)
    assert_equal(true, import_job_response.server_error?)
    assert_equal(:invalid_response_from_server, import_job_response.server_error)
    assert_equal('', import_job_response.headers_pretty_print)
    assert_equal('', import_job_response.body_pretty_print)
  end

  def test_valid_headers_and_nil_body
    headers_json = '{"expires":"0","destination":"/queue/plastron.jobs.completed","PlastronJobId":"http://localhost:3000/import_jobs/1","PlastronJobStatus":"Error","PlastronJobError":"Unrecognized header \"Volume\" in import file."}'
    body_json = nil
    import_job_response = ImportJobResponse.new(headers_json, body_json)
    assert_equal(false, import_job_response.valid?)
    assert_equal(true, import_job_response.server_error?)
    assert_equal(:invalid_response_from_server, import_job_response.server_error)
    assert_equal(JSON.pretty_generate(JSON.parse(headers_json)), import_job_response.headers_pretty_print)
    assert_equal('', import_job_response.body_pretty_print)
  end

  def test_valid_headers_and_empty_body
    headers_json = '{"expires":"0","destination":"/queue/plastron.jobs.completed","PlastronJobId":"http://localhost:3000/import_jobs/1","PlastronJobStatus":"Error","PlastronJobError":"Unrecognized header \"Volume\" in import file."}'
    body_json = ''
    import_job_response = ImportJobResponse.new(headers_json, body_json)
    assert_equal(false, import_job_response.valid?)
    assert_equal(true, import_job_response.server_error?)
    assert_equal(:invalid_response_from_server, import_job_response.server_error)
    assert_equal(JSON.pretty_generate(JSON.parse(headers_json)), import_job_response.headers_pretty_print)
    assert_equal('', import_job_response.body_pretty_print)
  end

  def test_valid_headers_and_invalid_body # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    headers_json = '{"expires":"0","destination":"/queue/plastron.jobs.completed"}'
    invalid_body_jsons = [
      '{ "foo": "bar" }',
      '{ "count": { "foo": "bar" } }',
      '{ "count": { "total": 1, "updated": 0, "unchanged": 0, "valid": 1, "invalid": 0, "errors": "abc" } }'
    ]

    invalid_body_jsons.each do |json|
      import_job_response = ImportJobResponse.new(headers_json, json)
      assert_equal(false, import_job_response.valid?, "JSON: #{json}")
      assert_equal(true, import_job_response.server_error?, "JSON: #{json}")
      assert_equal(:invalid_response_from_server, import_job_response.server_error, "JSON: #{json}")
      assert_equal(JSON.pretty_generate(JSON.parse(headers_json)), import_job_response.headers_pretty_print)
      assert_equal(JSON.pretty_generate(JSON.parse(json)), import_job_response.body_pretty_print)
    end
  end

  def test_valid_json_and_successful_validation # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    headers_json = '{"expires":"0","destination":"/queue/plastron.jobs.completed"}'
    valid_body_jsons = [
      '{ "count": { "total": 1, "updated": 0, "unchanged": 0, "valid": 1, "invalid": 0, "errors": 0 } }',
      '{ "count": { "total": 45, "updated": 0, "unchanged": 0, "valid": 45, "invalid": 0, "errors": 0 } }'
    ]

    valid_body_jsons.each do |json|
      import_job_response = ImportJobResponse.new(headers_json, json)
      assert_equal(true, import_job_response.valid?, "JSON: #{json}")
      assert_equal(false, import_job_response.server_error?, "JSON: #{json}")
      assert_nil import_job_response.server_error, "JSON: #{json}"
      assert import_job_response.num_valid.positive?, "JSON: #{json}"
      assert_equal(import_job_response.num_total,
                   import_job_response.num_valid + import_job_response.num_invalid + import_job_response.num_error,
                   "JSON: #{json}")
      assert_equal(0, import_job_response.num_invalid, "JSON: #{json}")
      assert_equal(0, import_job_response.num_error, "JSON: #{json}")
      assert_equal(JSON.pretty_generate(JSON.parse(headers_json)), import_job_response.headers_pretty_print)
      assert_equal(JSON.pretty_generate(JSON.parse(json)), import_job_response.body_pretty_print)
    end
  end

  def test_valid_json_and_failed_validation # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    headers_json = '{"expires":"0","destination":"/queue/plastron.jobs.completed"}'
    valid_body_jsons = [
      '{ "count": { "total": 2, "updated": 0, "unchanged": 0, "valid": 1, "invalid": 1, "errors": "0" }, "validation": [] }',
      '{ "count": { "total": 47, "updated": 0, "unchanged": 0, "valid": 45, "invalid": 0, "errors": 2 }, "validation": [] }'
    ]

    valid_body_jsons.each do |json|
      import_job_response = ImportJobResponse.new(headers_json, json)
      assert_equal(false, import_job_response.valid?, "JSON: #{json}")
      assert_equal(false, import_job_response.server_error?, "JSON: #{json}")
      assert_nil import_job_response.server_error, "JSON: #{json}"
      assert(import_job_response.num_invalid.positive? ||
             import_job_response.num_error.positive?, "JSON: #{json}")
      assert_equal(import_job_response.num_total,
                   import_job_response.num_valid + import_job_response.num_invalid + import_job_response.num_error,
                   "JSON: #{json}")
      assert_equal(JSON.pretty_generate(JSON.parse(headers_json)), import_job_response.headers_pretty_print)
      assert_equal(JSON.pretty_generate(JSON.parse(json)), import_job_response.body_pretty_print)
    end
  end

  def test_valid_json_and_failed_validation_with_invalid_data # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    headers_json = '{"expires":"0","destination":"/queue/plastron.jobs.completed"}'
    body_json = <<~JSON_END
      { "count": {"total": 1, "updated": 0, "unchanged": 0, "valid": 0, "invalid": 1, "errors": 0},
        "validation": [
          { "line": "<>:2", "is_valid": false,
            "passed": [
                        ["title", "passed", "exactly", 1],
                        ["date", "passed", "exactly", 1],
                        ["volume", "passed", "exactly", 1],
                        ["issue", "passed", "exactly", 1],
                        ["edition", "passed", "exactly", 1]
                      ],
            "failed": [
                        ["date", "failed", "value_pattern", "^\\d\\d\\d\\d-\\d\\d-\\d\\d$"]
                      ]
          }
        ]
      }
    JSON_END

    import_job_response = ImportJobResponse.new(headers_json, body_json)
    invalid_lines = import_job_response.invalid_lines

    assert_equal(false, import_job_response.valid?)
    assert_equal(1, invalid_lines.count)
    assert_equal('2', invalid_lines[0].line_location)
    assert_equal('date', invalid_lines[0].field_errors[0])
    assert_equal(JSON.pretty_generate(JSON.parse(headers_json)), import_job_response.headers_pretty_print)
    assert_equal(JSON.pretty_generate(JSON.parse(body_json)), import_job_response.body_pretty_print)
  end

  def test_valid_json_and_failed_validation_with_wrong_number_of_columns # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    headers_json = '{"expires":"0","destination":"/queue/plastron.jobs.completed"}'
    body_json = <<~JSON_END
      { "count": {"total": 1, "updated": 0, "unchanged": 0, "valid": 0, "invalid": 1, "errors": 0},
        "validation": [
          {
            "line": "<>:3",
            "is_valid": false,
            "error": "Line <>:3 has the wrong number of columns"
          }
        ]
      }
    JSON_END

    import_job_response = ImportJobResponse.new(headers_json, body_json)
    invalid_lines = import_job_response.invalid_lines

    assert_equal(false, import_job_response.valid?)
    assert_equal(1, invalid_lines.count)
    assert_equal('3', invalid_lines[0].line_location)
    assert_equal('Line <>:3 has the wrong number of columns', invalid_lines[0].line_error)
    assert_equal(JSON.pretty_generate(JSON.parse(headers_json)), import_job_response.headers_pretty_print)
    assert_equal(JSON.pretty_generate(JSON.parse(body_json)), import_job_response.body_pretty_print)
  end
end

# frozen_string_literal: true

require 'test_helper'

class ImportJobResponseTest < Minitest::Test
  def setup
  end

  def test_nil_response
    json = nil
    import_job_response = ImportJobResponse.new(json)
    assert_equal(false, import_job_response.valid?)
    assert_equal(true, import_job_response.server_error?)
    assert_equal(:invalid_response_from_server, import_job_response.server_error)
  end

  def test_empty_response
    json = ''
    import_job_response = ImportJobResponse.new(json)
    assert_equal(false, import_job_response.valid?)
    assert_equal(true, import_job_response.server_error?)
    assert_equal(:invalid_response_from_server, import_job_response.server_error)
  end

  def test_invalid_json # rubocop:disable Metrics/MethodLength
    invalid_jsons = [
      '{ "foo": "bar" }',
      '{ "count": { "foo": "bar" } }',
      '{ "count": { "total": 1, "updated": 0, "unchanged": 0, "valid": 1, "invalid": 0, "errors": "abc" } }'
    ]

    invalid_jsons.each do |json|
      import_job_response = ImportJobResponse.new(json)
      assert_equal(false, import_job_response.valid?, "JSON: #{json}")
      assert_equal(true, import_job_response.server_error?, "JSON: #{json}")
      assert_equal(:invalid_response_from_server, import_job_response.server_error, "JSON: #{json}")
    end
  end

  def test_valid_json_and_successful_validation # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    jsons = [
      '{ "count": { "total": 1, "updated": 0, "unchanged": 0, "valid": 1, "invalid": 0, "errors": 0 } }',
      '{ "count": { "total": 45, "updated": 0, "unchanged": 0, "valid": 45, "invalid": 0, "errors": 0 } }'
    ]

    jsons.each do |json|
      import_job_response = ImportJobResponse.new(json)
      assert_equal(true, import_job_response.valid?, "JSON: #{json}")
      assert_equal(false, import_job_response.server_error?, "JSON: #{json}")
      assert_nil import_job_response.server_error, "JSON: #{json}"
      assert import_job_response.num_valid.positive?, "JSON: #{json}"
      assert_equal(import_job_response.num_total,
                   import_job_response.num_valid + import_job_response.num_invalid + import_job_response.num_error,
                   "JSON: #{json}")
      assert_equal(0, import_job_response.num_invalid, "JSON: #{json}")
      assert_equal(0, import_job_response.num_error, "JSON: #{json}")
    end
  end

  def test_valid_json_and_failed_validation # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    jsons = [
      '{ "count": { "total": 2, "updated": 0, "unchanged": 0, "valid": 1, "invalid": 1, "errors": "0" }, "validation": [] }',
      '{ "count": { "total": 47, "updated": 0, "unchanged": 0, "valid": 45, "invalid": 0, "errors": 2 }, "validation": [] }'
    ]

    jsons.each do |json|
      import_job_response = ImportJobResponse.new(json)
      assert_equal(false, import_job_response.valid?, "JSON: #{json}")
      assert_equal(false, import_job_response.server_error?, "JSON: #{json}")
      assert_nil import_job_response.server_error, "JSON: #{json}"
      assert(import_job_response.num_invalid.positive? ||
             import_job_response.num_error.positive?, "JSON: #{json}")
      assert_equal(import_job_response.num_total,
                   import_job_response.num_valid + import_job_response.num_invalid + import_job_response.num_error,
                   "JSON: #{json}")
    end
  end

  def test_valid_json_and_failed_validation_with_invalid_date # rubocop:disable Metrics/MethodLength
    json = <<~JSON_END
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

    import_job_response = ImportJobResponse.new(json)
    invalid_lines = import_job_response.invalid_lines

    assert_equal(false, import_job_response.valid?)
    assert_equal(1, invalid_lines.count)
    assert_equal('2', invalid_lines[0].line_location)
    assert_equal('date', invalid_lines[0].field_errors[0])
  end

  def test_valid_json_and_failed_validation_with_wrong_number_of_columns # rubocop:disable Metrics/MethodLength
    json = <<~JSON_END
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

    import_job_response = ImportJobResponse.new(json)
    invalid_lines = import_job_response.invalid_lines

    assert_equal(false, import_job_response.valid?)
    assert_equal(1, invalid_lines.count)
    assert_equal('3', invalid_lines[0].line_location)
    assert_equal('Line <>:3 has the wrong number of columns', invalid_lines[0].line_error)
  end
end

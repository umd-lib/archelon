# frozen_string_literal: true

require 'test_helper'

class JsonRestResultTest < ActiveSupport::TestCase
  def setup
  end

  test 'create_error_result indicates error occurred' do
    result = JsonRestResult.create_error_result('404 Not Found')
    assert(result.error_occurred?)
    assert_equal('404 Not Found', result.error_message)
  end

  test 'create_from_json given nil stores returns JsonRestResult with error message' do
    result = JsonRestResult.create_from_json(nil)
    assert result.error_occurred?
    assert_equal('no implicit conversion of nil into String', result.error_message)
  end

  test 'create_from_json given empty string returns JsonRestResult with error message' do
    result = JsonRestResult.create_from_json('')
    assert result.error_occurred?
    assert_equal("767: unexpected token at ''", result.error_message)
  end

  test 'create_from_json given valid JSON string returns parsed hash' do
    result = JsonRestResult.create_from_json('{}')
    assert_not result.error_occurred?
    assert_equal('{}', result.raw_json)
    assert_not result.parsed_json.nil?
  end

  test 'create_from_json given complex JSON returns parsed hash' do # rubocop:disable Metrics/BlockLength
    sample_json = <<-JSON_END
      {
        "@id": "http://localhost:5000/jobs/http%253A%252F%252Flocalhost%253A3000%252Fimport_jobs%252F5",
        "access": "http://vocab.lib.umd.edu/access#Public",
        "binaries_location": "zip:///test.zip",
        "completed": {
          "count": 2,
          "items": [
            {
              "id": "image-id-0",
              "timestamp": "2021-07-28T14:06:38",
              "title": "Deimos",
              "uri": "http://fcrepo-local:8080/fcrepo/rest/dc/2016/solar-system/c4/c6/18/7d/c4c6187d-a7d1-4ec8-b7fe-7494eaaa2c48"
            },
            {
              "id": "image-id-1",
              "timestamp": "2021-07-28T14:06:50",
              "title": "Jupiter",
              "uri": "http://fcrepo-local:8080/fcrepo/rest/dc/2016/solar-system/7a/fe/74/7c/7afe747c-9c21-49d2-bcae-c5ac5a864da8"
            }
          ]
        },
        "container": "/dc/2016/solar-system",
        "job_id": "http://localhost:3000/import_jobs/5",
        "member_of": "http://fcrepo-local:8080/fcrepo/rest/dc/2016/solar-system",
        "model": "Item",
        "total": 2
      }
    JSON_END

    result = JsonRestResult.create_from_json(sample_json)
    parsed_json = result.parsed_json
    assert_equal('http://localhost:3000/import_jobs/5', parsed_json['job_id'])
    assert_equal(2, parsed_json['completed']['count'])
  end
end

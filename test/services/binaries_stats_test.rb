# frozen_string_literal: true

require 'test_helper'

class BinariesStatsTest < ActiveSupport::TestCase
  VALID_MIME_TYPES = ['image/jpeg', 'image/tiff'].freeze
  INVALID_MIME_TYPE = 'application/pdf'

  # Test when Solr response is empty
  test 'should return correct result when Solr response is empty' do
    solr_response = {}
    result = BinariesStats.process_solr_response(solr_response, VALID_MIME_TYPES)

    assert_equal 0, result[:count]
    assert_equal 0, result[:total_size]

    assert_equal 0, result[:count]
    assert_equal 0, result[:total_size]
  end

  # Test when Solr response contains one file with invalid MIME type
  test 'should return correct result with one file with invalid MIME type' do
    solr_response = {
      'response' => {
        'docs' => [
          {
            'object__has_member' => [
              {
                'page__has_file' => [
                  {
                    'file__mime_type__str' => INVALID_MIME_TYPE,
                    'file__size__int' => '1000'
                  }
                ]
              }
            ]
          }
        ]
      }
    }

    result = BinariesStats.process_solr_response(solr_response, VALID_MIME_TYPES)

    assert_equal 0, result[:count]
    assert_equal 0, result[:total_size]
  end

  # Test when Solr response contains one file with valid MIME type
  test 'should return correct result with one file with valid MIME type' do
    solr_response = {
      'response' => {
        'docs' => [
          {
            'object__has_member' => [
              {
                'page__has_file' => [
                  {
                    'file__mime_type__str' => VALID_MIME_TYPES[0],
                    'file__size__int' => '1000'
                  }
                ]
              }
            ]
          }
        ]
      }
    }

    result = BinariesStats.process_solr_response(solr_response, VALID_MIME_TYPES)

    assert_equal 1, result[:count]
    assert_equal 1000, result[:total_size]
  end

  # Test when Solr response contains files with multiple valid MIME types
  test 'should return correct result with multiple files with valid MIME types' do
    solr_response = {
      'response' => {
        'docs' => [
          {
            'object__has_member' => [
              {
                'page__has_file' => [
                  {
                    'file__mime_type__str' => VALID_MIME_TYPES[0],
                    'file__size__int' => '1000'
                  },
                  {
                    'file__mime_type__str' => VALID_MIME_TYPES[1],
                    'file__size__int' => '2048'
                  }
                ]
              }
            ]
          }
        ]
      }
    }

    result = BinariesStats.process_solr_response(solr_response, VALID_MIME_TYPES)

    assert_equal 2, result[:count]
    assert_equal 3048, result[:total_size]
  end

  # Test when "object__has_member" array has multiple entries, with valid and
  # invalid MIME types
  test 'should process multiple object__has_member entries' do # rubocop:disable Metrics/BlockLength
    solr_response = {
      'response' => {
        'docs' => [
          {
            'object__has_member' => [
              {
                'page__has_file' => [
                  {
                    'file__mime_type__str' => INVALID_MIME_TYPE,
                    'file__size__int' => '2048'
                  }
                ]
              },
              {
                'page__has_file' => [
                  {
                    'file__mime_type__str' => VALID_MIME_TYPES[0],
                    'file__size__int' => '128'
                  }
                ]
              },
              {
                'page__has_file' => [
                  {
                    'file__mime_type__str' => VALID_MIME_TYPES[1],
                    'file__size__int' => '256'
                  }
                ]
              },
              {
                'page__has_file' => [
                  {
                    'file__mime_type__str' => VALID_MIME_TYPES[1],
                    'file__size__int' => '512'
                  }
                ]
              }
            ]
          }
        ]
      }
    }

    result = BinariesStats.process_solr_response(solr_response, VALID_MIME_TYPES)

    assert_equal 3, result[:count]
    assert_equal (128 + 256 + 512), result[:total_size]
  end
end

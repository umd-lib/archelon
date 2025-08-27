# frozen_string_literal: true

require 'test_helper'

class MimeTypesTest < ActiveSupport::TestCase
  # Test when Solr response is empty
  test 'should return empty array when Solr response is empty' do
    solr_response = {}
    result = MimeTypes.process_solr_response(solr_response)
    assert_equal [], result
  end

  # Test when Solr response contains one MIME type
  test 'should return array with one MIME type' do
    solr_response = {
      'response' => {
        'docs' => [
          {
            'object__has_member' => [
              {
                'page__has_file' => [
                  { 'file__mime_type__str' => 'application/pdf' }
                ]
              }
            ]
          }
        ]
      }
    }
    result = MimeTypes.process_solr_response(solr_response)
    assert_equal ['application/pdf'], result
  end

  # Test when Solr response contains multiple MIME types
  test 'should return sorted array with multiple MIME types' do
    solr_response = {
      'response' => {
        'docs' => [
          {
            'object__has_member' => [
              {
                'page__has_file' => [
                  { 'file__mime_type__str' => 'application/pdf' },
                  { 'file__mime_type__str' => 'image/jpeg' }
                ]
              }
            ]
          }
        ]
      }
    }
    result = MimeTypes.process_solr_response(solr_response)
    assert_equal ['application/pdf', 'image/jpeg'], result
  end

  # Test when Solr response contains duplicate MIME types
  test 'should return array with unique MIME types' do
    solr_response = {
      'response' => {
        'docs' => [
          {
            'object__has_member' => [
              {
                'page__has_file' => [
                  { 'file__mime_type__str' => 'application/pdf' },
                  { 'file__mime_type__str' => 'application/pdf' }
                ]
              }
            ]
          }
        ]
      }
    }
    result = MimeTypes.process_solr_response(solr_response)
    assert_equal ['application/pdf'], result
  end

  # Test when Solr response contains nil MIME types
  test 'should ignore nil MIME types' do
    solr_response = {
      'response' => {
        'docs' => [
          {
            'object__has_member' => [
              {
                'page__has_file' => [
                  { 'file__mime_type__str' => 'application/pdf' },
                  { 'file__mime_type__str' => nil }
                ]
              }
            ]
          }
        ]
      }
    }
    result = MimeTypes.process_solr_response(solr_response)
    assert_equal ['application/pdf'], result
  end

  # Test when "object__has_member" array has multiple entries
  test 'should process multiple object__has_member entries' do
    solr_response = {
      'response' => {
        'docs' => [
          {
            'object__has_member' => [
              {
                'page__has_file' => [
                  { 'file__mime_type__str' => 'application/pdf' }
                ]
              },
              {
                'page__has_file' => [
                  { 'file__mime_type__str' => 'image/png' }
                ]
              }
            ]
          }
        ]
      }
    }
    result = MimeTypes.process_solr_response(solr_response)
    assert_equal ['application/pdf', 'image/png'], result
  end

  # Test when "docs" array has multiple entries
  test 'should process multiple docs entries' do # rubocop:disable Metrics/BlockLength
    solr_response = {
      'response' => {
        'docs' => [
          {
            'object__has_member' => [
              {
                'page__has_file' => [
                  { 'file__mime_type__str' => 'application/pdf' }
                ]
              }
            ]
          },
          {
            'object__has_member' => [
              {
                'page__has_file' => [
                  { 'file__mime_type__str' => 'text/plain' }
                ]
              }
            ]
          }
        ]
      }
    }
    result = MimeTypes.process_solr_response(solr_response)
    assert_equal ['application/pdf', 'text/plain'], result
  end
end

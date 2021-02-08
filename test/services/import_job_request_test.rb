# frozen_string_literal: true

require 'test_helper'

class ImportJobRequestTest < ActiveSupport::TestCase
  def setup
  end

  test 'headers for "flat" collections' do
    with_constant('FCREPO_BASE_URL', 'http://example.com/rest') do
      import_job = import_jobs(:one)
      import_job.collection = 'http://example.com/rest/pcdm'
      assert_equal :flat, import_job.collection_structure

      import_job_request = ImportJobRequest.new('test', import_job, false)
      headers = import_job_request.headers
      assert_equal('flat', headers[:'PlastronArg-structure'])
      assert_equal('/pcdm', headers[:'PlastronArg-relpath'])
    end
  end

  test 'headers for "hierarchical" collections' do
    with_constant('FCREPO_BASE_URL', 'http://example.com/rest') do
      import_job = import_jobs(:one)
      import_job.collection = 'http://example.com/rest/dc/2021/2'
      assert_equal :hierarchical, import_job.collection_structure

      import_job_request = ImportJobRequest.new('test', import_job, false)
      headers = import_job_request.headers
      assert_equal('hierarchical', headers[:'PlastronArg-structure'])
      assert_equal('/dc/2021/2', headers[:'PlastronArg-relpath'])
    end
  end
end

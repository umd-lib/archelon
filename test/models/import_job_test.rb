# frozen_string_literal: true

require 'test_helper'

class ImportJobTest < ActiveSupport::TestCase
  test 'binaries? indicates whether the import job has a binary zip file or remote server' do
    import_job = import_jobs(:import_job_without_binaries)
    assert_equal false, import_job.binaries?

    import_job = import_jobs(:import_job_with_binaries_location)
    assert import_job.binaries?
  end

  test 'collection_relpath returns the proper relative path' do
    # Test for base urls with and without final slash
    test_base_urls = %w[http://fcrepo-base-url.com/rest http://fcrepo-base-url.com/rest/]

    # [Collection, Expected relative path]
    test_collections = [
      ["http://fcrepo-base-url.com/rest#{ImportJob::FLAT_LAYOUT_RELPATH}", ImportJob::FLAT_LAYOUT_RELPATH],
      ["http://fcrepo-base-url.com/rest#{ImportJob::FLAT_LAYOUT_RELPATH}/51/a4/54/a8/51a454a8-7ad0-45dd-ba2b-85632fe1b618", ImportJob::FLAT_LAYOUT_RELPATH],
      ['http://fcrepo-base-url.com/rest/dc/2021/2', '/dc/2021/2']
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

  test 'collection_relpath returns the proper relative path for external urls' do
    # Test for external urls with and without final slash
    test_external_urls = %w[http://external-url.com/rest http://external-url.com/rest/]

    test_collections = [
      # [Collection, Expected relative path]
      ["http://external-url.com/rest#{ImportJob::FLAT_LAYOUT_RELPATH}", ImportJob::FLAT_LAYOUT_RELPATH],
      ["http://external-url.com/rest#{ImportJob::FLAT_LAYOUT_RELPATH}/51/a4/54/a8/51a454a8-7ad0-45dd-ba2b-85632fe1b618", ImportJob::FLAT_LAYOUT_RELPATH],
      ['http://external-url.com/rest/dc/2021/2', '/dc/2021/2']
    ]

    test_external_urls.each do |external_url|
      with_constant('REPO_EXTERNAL_URL', external_url) do
        test_collections.each do |collection, expected_relpath|
          import_job = ImportJob.new
          import_job.collection = collection
          assert_equal expected_relpath, import_job.collection_relpath, "Using external_url: '#{external_url}'"
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

  test 'update_progress should reflect progress in message' do
    import_job = import_jobs(:one)
    assert_nil import_job.progress

    stomp_message = Stomp::Message.new('')
    stomp_message.body = {
      'time': {
        'started': 1_612_895_677.028775,
        'now': 1_612_895_784.956666,
        'elapsed': 107.92789101600647
      },
      'count': {
        'total': 25,
        'rows': 25,
        'errors': 1,
        'valid': 5,
        'invalid': 0,
        'created': 2,
        'updated': 1,
        'unchanged': 1,
        'files': 25
      }
    }.to_json

    plastron_message = PlastronMessage.new(stomp_message)
    import_job.update_progress(plastron_message)
    assert_equal 20, import_job.progress # (errors + created + updated + unchanged) = 5, 5/25 = 20%
  end
end

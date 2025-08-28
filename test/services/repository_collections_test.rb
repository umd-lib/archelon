# frozen_string_literal: true

require 'test_helper'

class RepositoryCollectionsTest < ActiveSupport::TestCase
  def setup
  end

  test 'no Solr connection' do
    Blacklight::Solr::Repository.any_instance.stub(:search).and_raise(Blacklight::Exceptions::ECONNREFUSED)

    assert_raise(Blacklight::Exceptions::ECONNREFUSED) do
      RepositoryCollections.list
    end
  end

  test 'invalid Solr request' do
    Blacklight::Solr::Repository.any_instance.stub(:search).and_raise(Blacklight::Exceptions::InvalidRequest)

    assert_raise(Blacklight::Exceptions::InvalidRequest) do
      RepositoryCollections.list
    end
  end

  test 'valid Solr response - no collections' do
    stub_repository_collections_solr_response('services/repository_collections/solr_response_no_collections.json')

    collections = RepositoryCollections.list

    assert_equal 0, collections.size
  end

  test 'valid Solr response - one collection' do
    stub_repository_collections_solr_response('services/repository_collections/solr_response_one_collection.json')

    collections = RepositoryCollections.list

    assert_equal 1, collections.size
    assert_equal 'Student Newspapers', collections[0][:display_title]
    assert_equal 'https://fcrepolocal/fcrepo/rest/pcdm/93/82/84/73/93828473-c387-481b-82e4-e7c00992c983', collections[0][:uri]
  end

  test 'valid Solr response - multiple collections' do
    stub_repository_collections_solr_response('services/repository_collections/solr_response_multiple_collections.json')

    collections = RepositoryCollections.list

    assert_equal 4, collections.size

    # Verify collections are sorted by display_title
    display_titles = collections.pluck(:display_title)
    display_titles_sorted = display_titles.sort
    assert_equal display_titles_sorted, display_titles
  end
end

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
    Blacklight::Solr::Repository.any_instance.stub(:search).and_return(valid_solr_response_no_collections)

    collections = RepositoryCollections.list

    assert_equal 0, collections.size
  end

  test 'valid Solr response - one collection' do
    Blacklight::Solr::Repository.any_instance.stub(:search).and_return(valid_solr_response_one_collection)

    collections = RepositoryCollections.list

    assert_equal 1, collections.size
    assert_equal 'Student Newspapers', collections[0][:display_title]
    assert_equal 'https://fcrepolocal/fcrepo/rest/pcdm/93/82/84/73/93828473-c387-481b-82e4-e7c00992c983', collections[0][:uri]
  end

  test 'valid Solr response - multiple collections' do
    Blacklight::Solr::Repository.any_instance.stub(:search).and_return(valid_solr_response_multiple_collections)

    collections = RepositoryCollections.list

    assert_equal 4, collections.size

    # Verify collections are sorted by display_title
    display_titles = collections.map { |c| c[:display_title] }
    display_titles_sorted = display_titles.sort
    assert_equal display_titles_sorted, display_titles
  end

  # Helper methods

  def valid_solr_response_no_collections
    file = file_fixture('services/repository_collections/solr_response_no_collections.json').read
    data_hash = JSON.parse(file)

    Blacklight::Solr::Response.new(data_hash, nil)
  end

  def valid_solr_response_one_collection
    file = file_fixture('services/repository_collections/solr_response_one_collection.json').read
    data_hash = JSON.parse(file)

    Blacklight::Solr::Response.new(data_hash, nil)
  end

  def valid_solr_response_multiple_collections
    file = file_fixture('services/repository_collections/solr_response_multiple_collections.json').read
    data_hash = JSON.parse(file)

    Blacklight::Solr::Response.new(data_hash, nil)
  end
end

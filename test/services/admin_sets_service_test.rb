# frozen_string_literal: true

require 'test_helper'

class AdminSetsServiceTest < ActiveSupport::TestCase
  def setup
  end

  test 'no Solr connection' do
    Blacklight::Solr::Repository.any_instance.stub(:search).and_raise(Blacklight::Exceptions::ECONNREFUSED)

    assert_raise(Blacklight::Exceptions::ECONNREFUSED) do
      AdminSetsService.list
    end
  end

  test 'invalid Solr request' do
    Blacklight::Solr::Repository.any_instance.stub(:search).and_raise(Blacklight::Exceptions::InvalidRequest)

    assert_raise(Blacklight::Exceptions::InvalidRequest) do
      AdminSetsService.list
    end
  end

  test 'valid Solr response - no collections' do
    stub_admin_sets_service_solr_response('services/admin_sets_service/solr_response_no_collections.json')

    collections = AdminSetsService.list

    assert_equal 0, collections.size
  end

  test 'valid Solr response - one collection' do
    stub_admin_sets_service_solr_response('services/admin_sets_service/solr_response_one_collection.json')

    collections = AdminSetsService.list

    assert_equal 1, collections.size
    assert_equal 'UMD Student Newspapers', collections[0][:display_title]
    assert_equal 'https://fcrepo-test.lib.umd.edu/fcrepo/rest/pcdm/9d/05/57/c2/9d0557c2-825f-4e33-8a52-a6d70145878e', collections[0][:uri]
  end

  test 'valid Solr response - multiple collections' do
    stub_admin_sets_service_solr_response('services/admin_sets_service/solr_response_multiple_collections.json')

    collections = AdminSetsService.list

    assert_equal 4, collections.size

    # Verify collections are sorted by display_title
    display_titles = collections.pluck(:display_title)
    display_titles_sorted = display_titles.sort
    assert_equal display_titles_sorted, display_titles
  end
end

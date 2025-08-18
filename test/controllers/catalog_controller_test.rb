# frozen_string_literal: true

require 'test_helper'

class CatalogControllerTest < ActionController::TestCase
  setup do
    @cas_user = cas_users(:one)
    mock_cas_login(@cas_user.cas_directory_id)
  end

  test 'should give warning and redirect if solr is down' do
    raise_e = -> { raise Blacklight::Exceptions::ECONNREFUSED }
    @controller.stub(:index, raise_e) do
      get :index
      assert_redirected_to(about_url)
      assert_not flash.empty?
      assert_equal flash[:error], I18n.t(:solr_is_down)
    end
  end

  test 'should give warning and redirect if solr cannot connect' do
    raise_e = -> { raise Blacklight::Exceptions::InvalidRequest }
    @controller.stub(:index, raise_e) do
      get :index
      assert_redirected_to(about_url)
      assert_not flash.empty?
      assert_equal flash[:error], I18n.t(:solr_is_down)
    end
  end

  test 'show_edit_metadata? should be "true" for top-level components' do
    assert CatalogController.show_edit_metadata?('Issue')
  end

  test 'show_edit_metadata? should be "false" for non-top-level components' do
    assert_not CatalogController.show_edit_metadata?('Article')
    assert_not CatalogController.show_edit_metadata?('Page')
  end

  test 'should redirect to item detail page on identifier search with a single match' do
    # Inject the stubbed search_results_mock into the controller
    # UMD Blacklight 8 Fix
    stub_search_results_single_result
    get :index, params: { q: '"test:123"' }

    # Assert that the request was redirected to the show method with the correct ID param
    assert_redirected_to(controller: 'catalog', action: 'show', id: 'http://fcrepo-test/123')
    # End UMD Blacklight 8 Fix
  end

  test 'should not redirect to item detail page regular search with a single match' do
    # Inject the stubbed search_results_mock into the controller
    # UMD Blacklight 8 Fix
    stub_search_results_single_result
    get :index, params: { q: 'test' }

    # Assert that the request was not redirected
    assert_response(:success)
    # End UMD Blacklight 8 Fix
  end

  private

    # Stubs the DownloadUrlsController.search_results call, so that it
    # won't actually make a network call. Returns a sample SolrDocument
    #
    # Usage:
    #
    # stub_search_results do
    #   <Code that calls "search_results">
    # end
    def stub_search_results_single_result
      # Mock objects for response and document_list
      bl_config = @controller.blacklight_config
      response_mock = bl_config.response_model.new(mock_query_response('', 1, mock_solr_doc), {}, document_model: bl_config.document_model, blacklight_config: bl_config)

      # UMD Blacklight 8 Fix
      expect_any_instance_of(Blacklight::SearchService).to receive(:search_results).and_return(response_mock)
      # End UMD Blacklight 8 Fix
    end

    def mock_query_response(query = '*:*', num_found = 0, doc = mock_solr_doc)
      { 'responseHeader' => { 'status' => 0, 'QTime' => 12, 'params' => { 'f.author_not_tokenized.facet.limit' => '11', 'facet.field' => %w[collection_title_facet presentation_set_label author_not_tokenized type component_not_tokenized rdf_type visibility publication_status], 'hl' => 'true', 'f.presentation_set_label.facet.sort' => 'index', 'f.collection_title_facet.facet.limit' => '11', 'f.presentation_set_label.facet.limit' => '11', 'fq' => 'is_pcdm:true OR rdf_type:oa\\:Annotation', 'sort' => 'score desc, display_title asc', 'rows' => '10', 'f.extracted_text.hl.fragsize' => '500', 'q' => query, 'f.component_not_tokenized.facet.limit' => '11', 'f.rdf_type.facet.limit' => '11', 'f.type.facet.limit' => '11', 'hl.fl' => 'extracted_text', 'facet' => 'true', 'wt' => 'json', 'f.collection_title_facet.facet.sort' => 'index' } }, 'response' => { 'numFound' => num_found, 'start' => 0, 'maxScore' => 4.373658, 'docs' => [doc] }, 'facet_counts' => { 'facet_queries' => {}, 'facet_fields' => { 'collection_title_facet' => ['The Katherine Anne Porter Correspondence Collection', 1], 'presentation_set_label' => [], 'author_not_tokenized' => ['Porter, Katherine Anne, 1890-1980', 1], 'type' => [], 'component_not_tokenized' => ['Letter', 1], 'rdf_type' => ['bibo:Letter', 1, 'fedora:Container', 1, 'fedora:Resource', 1, 'ldp:Container', 1, 'ldp:RDFSource', 1, 'pcdm:Object', 1, 'umdaccess:Public', 1], 'visibility' => ['Visible', 1], 'publication_status' => ['Unpublished', 1] }, 'facet_ranges' => {}, 'facet_intervals' => {}, 'facet_heatmaps' => {} }, 'highlighting' => { 'http://fcrepo-test/fcrepo/rest/pcdm/dd/96/d9/b4/dd96d9b4-4fa5-4a85-81ff-7dc79100c6f9' => {} } }
    end

    def mock_solr_doc
      { 'date' => '1948-07-19T00:00:00Z', 'extent' => ['1 page'], 'collection_title_facet' => ['Test Collection'], 'subject' => ['Porter, Katherine Anne, 1890-1980. Correspondence. Selections'], 'pcdm_members' => ['http://fcrepo-test/fcrepo/rest/pcdm/ed/6b/2e/63/ed6b2e63-fbd1-496c-8ba0-4879b90feb75'], 'geoname' => ['http://sws.geonames.org/5000306'], 'id' => 'http://fcrepo-test/123', 'last_modified' => '2024-04-19T15:15:56.118Z', 'identifier' => ['umd:85589'], 'created' => '2023-10-04T18:26:39.423Z', 'author' => ['Porter, Katherine Anne, 1890-1980'], 'author_not_tokenized' => ['Porter, Katherine Anne, 1890-1980'], 'collection' => ['http://fcrepo-test/fcrepo/rest/pcdm/3c/8e/8e/70/3c8e8e70-863c-4ac1-9819-139051292800'], 'created_by' => 'plastron', 'description' => ['Letter from Katherine Anne Porter to Gay Porter Holloway, July 19, 1948, typed. From Ann Heintze papers, Series 1, Box 1, Folder 7, Item 7. For complete collection information, visit the full finding aid at http://hdl.handle.net/1903.1/1497.'], 'title' => ['Letter from Katherine Anne Porter to Gay Porter Holloway, July 19, 1948'], 'rights' => ['http://rightsstatements.org/vocab/InC-NC/1.0/'], 'pcdm_member_of' => ['http://fcrepo-test/fcrepo/rest/pcdm/3c/8e/8e/70/3c8e8e70-863c-4ac1-9819-139051292800'], 'citation' => ['Ann Heintze papers, Series 1, Box 1, Folder 7, Item 7'], 'author_with_uri' => ['Porter, Katherine Anne, 1890-1980|http://viaf.org/viaf/56620604'], 'last_modified_by' => 'http://xmlns.com/foaf/0.1/Agent', 'recipient' => ['Holloway, Gay Porter, 1885-1969'], 'recipient_not_tokenized' => ['Holloway, Gay Porter, 1885-1969'], 'location' => ['Ludington, Michigan'], 'location_not_tokenized' => ['Ludington, Michigan'], 'recipient_with_uri' => ['Holloway, Gay Porter, 1885-1969|'], 'rdf_type' => ['fedora:Container', 'fedora:Resource', 'pcdm:Object', 'bibo:Letter', 'umdaccess:Public', 'ldp:Container', 'ldp:RDFSource'], 'is_pcdm' => true, 'component' => 'Letter', 'component_not_tokenized' => 'Letter', 'display_title' => 'Letter from Katherine Anne Porter to Gay Porter Holloway, July 19, 1948', 'display_date' => '1948-07-19', 'sort_date' => '1948-07-19', 'date_month' => '06::July', 'date_year' => 1948, 'date_decade' => '1940 - 1949', 'genre' => ['Letters'], 'timestamp' => '2023-10-04T18:26:44.313Z', 'is_published' => false, 'is_hidden' => false, 'is_top_level' => false, 'publication_status' => 'Unpublished', 'visibility' => 'Visible', 'is_discoverable' => false, '_version_' => 1_796_776_664_202_477_600, 'score' => 4.373658, 'annotation_source_info' => { 'numFound' => 0, 'start' => 0, 'docs' => [] } }
    end
end

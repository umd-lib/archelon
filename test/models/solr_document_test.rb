# frozen_string_literal: true

require 'test_helper'

class SolrDocumentTest < ActiveSupport::TestCase
  test 'display_titles returns empty string when no object__title__display' do
    solr_doc = SolrDocument.new(
      id: 'http://www.example.com'
    )
    assert_equal '', solr_doc.display_titles
  end

  test 'display_titles returns concatenated title without language tags' do
    test_cases = [
      { test_value: [], expected: '' },
      { test_value: [''], expected: '' },
      { test_value: ['Test Title'], expected: 'Test Title' },
      { test_value: ['Test Title', '[@ja]Japanese Title'], expected: 'Test Title | Japanese Title' }
    ]

    test_cases.each do |test_case|
      test_case => { test_value:, expected: }
      solr_doc = SolrDocument.new(
        id: 'http://www.example.com',
        object__title__display: test_value
      )

      assert_equal expected, solr_doc.display_titles, "'#{test_value} did not return '#{expected}'"
    end
  end

  test 'members_anchor returns Archelon-based relative URLs' do
    test_cases = [
      # test_value: [page_label_sequence__txts, page_uri_sequence__uris]
      # expected: [solr_document_path(test_value[1])]
      { test_value: [nil, nil], expected: nil },
      {
        test_value: [['Page 1'], ['http://fcrepo.test.example/page1']],
        expected: ['<a href="/catalog/http:%2F%2Ffcrepo.test.example%2Fpage1">Page 1</a>']
      },
      {
        test_value: [['Page 1', 'Page 2'], ['http://fcrepo.test.example/page1', 'http://fcrepo.test.example/page2']],
        expected: [
          '<a href="/catalog/http:%2F%2Ffcrepo.test.example%2Fpage1">Page 1</a>',
          '<a href="/catalog/http:%2F%2Ffcrepo.test.example%2Fpage2">Page 2</a>'
        ]
      }
    ]

    test_cases.each do |test_case|
      test_case => { test_value:, expected: }

      solr_params = { id: 'http://www.example.com' }
      solr_params[:page_label_sequence__txts] = test_value[0] if test_value[0]
      solr_params[:page_uri_sequence__uris] = test_value[1] if test_value[1]
      solr_doc = SolrDocument.new(
        **solr_params
      )

      assert_equal expected, solr_doc.members_anchor, "'#{test_value} did not return '#{expected}'"
    end
  end
end

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

  test 'displayable? should be "true" for top-level components' do
    %w[Item Issue].each do |content_model_name|
      doc = SolrDocument.new({ content_model_name__str: content_model_name })
      assert doc.displayable?
    end
  end

  test 'displayable? should be "false" for non-top-level components' do
    %w[Article Page File].each do |content_model_name|
      doc = SolrDocument.new({ content_model_name__str: content_model_name })
      assert_not doc.displayable?
    end
  end

  test 'editable? should be "true" for top-level components' do
    %w[Item Issue].each do |content_model_name|
      doc = SolrDocument.new({ content_model_name__str: content_model_name })
      assert doc.editable?
    end
  end

  test 'editable? should be "false" for non-top-level components' do
    %w[Article Page File].each do |content_model_name|
      doc = SolrDocument.new({ content_model_name__str: content_model_name })
      assert_not doc.editable?
    end
  end

  test 'highlighted extracted text should be HTML-escaped' do
    test_cases = [
      { snippet: 'foo', expected: 'foo' },
      { snippet: "*'<s", expected: '*&#39;&lt;s' },
      { snippet: "in \u{fff9}Portland\u{fffb}, ME", expected: 'in <b class="hl">Portland</b>, ME' },
      { snippet: "in \u{fff9}<Portland>\u{fffb}, ME", expected: 'in <b class="hl">&lt;Portland&gt;</b>, ME' }
    ]
    test_cases.each do |test_case|
      response = { highlighting: { 'http://example.com/foo': { extracted_text__dps_txt: [test_case[:snippet]] } } }.with_indifferent_access
      doc = SolrDocument.new({ id: 'http://example.com/foo' }, response)
      assert_equal [test_case[:expected]], doc.extracted_text
    end
  end
end

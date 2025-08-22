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
end

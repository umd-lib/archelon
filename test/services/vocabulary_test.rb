# frozen_string_literal: true

require 'test_helper'

class VocabularyTest < ActiveSupport::TestCase
  test 'term returns nil when term is not in vocabulary' do
    empty_vocabulary = Vocabulary.new('empty', [])
    assert_nil empty_vocabulary.term('http://vocab.lib.umd.edu/empty#not-in-vocabulary')

    json_fixture_file = 'sample_vocabularies/rightsStatement.json'
    stub_request(:get, 'http://vocab.lib.umd.edu/rightsStatement')
      .to_return(status: 200, body: file_fixture(json_fixture_file).read, headers: {})
    rights_vocabulary = VocabularyService.get_vocabulary('rightsStatement')

    assert_nil rights_vocabulary.term('http://vocab.lib.umd.edu/rightsStatement#not-in-vocabulary')
  end

  test 'term returns VocabularyTerm when term is in vocabulary' do
    json_fixture_file = 'sample_vocabularies/rightsStatement.json'
    stub_request(:get, 'http://vocab.lib.umd.edu/rightsStatement')
      .to_return(status: 200, body: file_fixture(json_fixture_file).read, headers: {})
    rights_vocabulary = VocabularyService.get_vocabulary('rightsStatement')

    term = rights_vocabulary.term('http://vocab.lib.umd.edu/rightsStatement#InC-EDU')
    assert_not_nil term
    assert_equal('InC-EDU', term.identifier)
    assert_equal('http://vocab.lib.umd.edu/rightsStatement#InC-EDU', term.uri)
    assert_equal('http://rightsstatements.org/vocab/InC-EDU/1.0/', term.same_as)
  end
end

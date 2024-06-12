# frozen_string_literal: true

require 'test_helper'

class VocabularyServiceTest < ActiveSupport::TestCase
  def setup
    item_content_model = CONTENT_MODELS[:Item]
    @rights_field = field_from_content_model(item_content_model, 'required', 'rights')
    @access_field = field_from_content_model(item_content_model, 'required', 'access')
    @collection_field = field_from_content_model(item_content_model, 'recommended', 'archival_collection')
  end

  test 'get_vocabulary returns Vocab object with empty terms when vocabulary does not exists' do
    stub_request(:get, 'http://vocab.lib.umd.edu/does-not-exist')
      .to_return(status: 404)
    vocab = VocabularyService.get_vocabulary('does-not-exist')
    assert_not_nil vocab
    assert_equal('does-not-exist', vocab.identifier)
    assert vocab.terms.empty?
  end

  test 'get_vocabulary returns Vocab object with empty terms when a parsing error occurs' do
    invalid_json = '{'
    stub_request(:get, 'http://vocab.lib.umd.edu/invalid_json')
      .to_return(status: 200, body: invalid_json, headers: {})
    vocab = VocabularyService.get_vocabulary('invalid_json')
    assert_not_nil vocab
    assert_equal('invalid_json', vocab.identifier)
    assert vocab.terms.empty?
  end

  test 'vocab_options_hash returns empty hash when given nil or empty content model field' do
    assert_equal({}, VocabularyService.vocab_options_hash(nil))
    assert_equal({}, VocabularyService.vocab_options_hash({}))
    assert_equal({}, VocabularyService.vocab_options_hash([]))
  end

  test 'vocab_options_hash returns empty hash on standard error' do
    stub_request(:get, 'http://vocab.lib.umd.edu/rightsStatement')
      .to_raise(StandardError)

    vocab_options_hash = VocabularyService.vocab_options_hash(@rights_field)
    assert_equal({}, vocab_options_hash)
  end

  test 'vocab_options_hash returns empty hash on HTTP connection error' do
    stub_request(:get, 'http://vocab.lib.umd.edu/rightsStatement')
      .to_raise(HTTP::ConnectionError)

    vocab_options_hash = VocabularyService.vocab_options_hash(@rights_field)
    assert_equal({}, vocab_options_hash)
  end

  test 'vocab_options_hash returns empty hash on network timeout' do
    stub_request(:get, 'http://vocab.lib.umd.edu/rightsStatement')
      .to_timeout

    vocab_options_hash = VocabularyService.vocab_options_hash(@rights_field)
    assert_equal({}, vocab_options_hash)
  end

  test 'vocab_options_hash returns empty hash unparseable JSON is returned' do
    invalid_json = '{'
    stub_request(:get, 'http://vocab.lib.umd.edu/rightsStatement')
      .to_return(status: 200, body: invalid_json, headers: {})

    vocab_options_hash = VocabularyService.vocab_options_hash(@rights_field)
    assert_equal({}, vocab_options_hash)
  end

  test 'vocab_options_hash returns options list when given vocabulary with one term' do
    # The JSON from vocabularies with only one term do not have the "@graph"
    # element that is present when vocabularies have two or more terms.
    json_fixture_file = 'sample_vocabularies/one_term_vocabulary.json'
    stub_request(:get, 'http://vocab.lib.umd.edu/collection')
      .to_return(status: 200, body: file_fixture(json_fixture_file).read, headers: {})

    expected_hash = { 'http://vocab.lib.umd.edu/collection#0001-GDOC' => 'United States Government Posters' }

    vocab_options_hash = VocabularyService.vocab_options_hash(@collection_field)
    assert_equal(expected_hash, vocab_options_hash)
  end

  test 'vocab_options_hash returns options list when given value content model field' do
    json_fixture_file = 'sample_vocabularies/rightsStatement.json'
    stub_request(:get, 'http://vocab.lib.umd.edu/rightsStatement')
      .to_return(status: 200, body: file_fixture(json_fixture_file).read, headers: {})

    expected_hash = {
      'http://vocab.lib.umd.edu/rightsStatement#CNE' => 'Copyright Not Evaluated',
      'http://vocab.lib.umd.edu/rightsStatement#UND' => 'Copyright Undetermined',
      'http://vocab.lib.umd.edu/rightsStatement#InC' => 'In Copyright',
      'http://vocab.lib.umd.edu/rightsStatement#InC-EDU' => 'In Copyright - Educational Use Permitted',
      'http://vocab.lib.umd.edu/rightsStatement#InC-NC' => 'In Copyright - Non-Commercial Use Permitted',
      'http://vocab.lib.umd.edu/rightsStatement#InC-RUU' => 'In Copyright - Rights-Holder(s) Unlocatable or Unidentifiable',
      'http://vocab.lib.umd.edu/rightsStatement#NoC-US' => 'No Copyright - United States',
      'http://vocab.lib.umd.edu/rightsStatement#NKC' => 'No Known Copyright'
    }

    vocab_options_hash = VocabularyService.vocab_options_hash(@rights_field)
    assert_equal(expected_hash, vocab_options_hash)
  end

  test 'vocab_options_hash returns options list with only allowed terms when terms are provided' do
    json_fixture_file = 'sample_vocabularies/access.json'
    stub_request(:get, 'http://vocab.lib.umd.edu/access')
      .to_return(status: 200, body: file_fixture(json_fixture_file).read, headers: {})

    expected_hash = {
      'http://vocab.lib.umd.edu/access#Public' => 'Public',
      'http://vocab.lib.umd.edu/access#Campus' => 'Campus'
    }

    vocab_options_hash = VocabularyService.vocab_options_hash(@access_field)
    assert_equal(expected_hash, vocab_options_hash)
  end

  # Returns a specific field the given section of a content_model
  # Section refers to the "required", "recommended" and "optional" sections
  # in the model.
  def field_from_content_model(content_model, section, field_name)
    section_fields = content_model[section]
    section_fields.each.select { |e| (e['name'] == field_name) }.first
  end
end

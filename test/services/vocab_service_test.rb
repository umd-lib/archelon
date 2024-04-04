# frozen_string_literal: true

require 'test_helper'

class VocabServiceTest < ActiveSupport::TestCase
  def setup
    item_content_model = CONTENT_MODELS[:Item]
    @rights_field = field_from_content_model(item_content_model, 'required', 'rights')
    @access_field = field_from_content_model(item_content_model, 'required', 'access')
  end

  test 'vocab_hash returns empty hash when given nil or empty content model field' do
    assert_equal({}, VocabService.vocab_options_hash(nil))
    assert_equal({}, VocabService.vocab_options_hash({}))
    assert_equal({}, VocabService.vocab_options_hash([]))
  end

  test 'vocab_hash returns empty hash on standard error' do
    stub_request(:get, 'http://vocab.lib.umd.edu/rightsStatement')
      .to_raise(StandardError)

    vocab_hash = VocabService.vocab_options_hash(@rights_field)
    assert_equal({}, vocab_hash)
  end

  test 'vocab_hash returns empty hash on HTTP connection error' do
    stub_request(:get, 'http://vocab.lib.umd.edu/rightsStatement')
      .to_raise(HTTP::ConnectionError)

    vocab_hash = VocabService.vocab_options_hash(@rights_field)
    assert_equal({}, vocab_hash)
  end

  test 'vocab_hash returns empty hash on network timeout' do
    stub_request(:get, 'http://vocab.lib.umd.edu/rightsStatement')
      .to_timeout

    vocab_hash = VocabService.vocab_options_hash(@rights_field)
    assert_equal({}, vocab_hash)
  end

  test 'vocab_hash returns empty hash unparseable JSON is returned' do
    invalid_json = '{'
    stub_request(:get, 'http://vocab.lib.umd.edu/rightsStatement')
      .to_return(status: 200, body: invalid_json, headers: {})

    vocab_hash = VocabService.vocab_options_hash(@rights_field)
    assert_equal({}, vocab_hash)
  end

  test 'vocab_hash returns options list when given value content model field' do
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

    vocab_hash = VocabService.vocab_options_hash(@rights_field)
    assert_equal(expected_hash, vocab_hash)
  end

  test 'vocab_hash returns options list with only allowed terms when terms are provided' do
    json_fixture_file = 'sample_vocabularies/access.json'
    stub_request(:get, 'http://vocab.lib.umd.edu/access')
      .to_return(status: 200, body: file_fixture(json_fixture_file).read, headers: {})

    expected_hash = {
      'http://vocab.lib.umd.edu/access#Public' => 'Public',
      'http://vocab.lib.umd.edu/access#Campus' => 'Campus'
    }

    vocab_hash = VocabService.vocab_options_hash(@access_field)
    assert_equal(expected_hash, vocab_hash)
  end

  # Returns a specific field the given section of a content_model
  # Section refers to the "required", "recommended" and "optional" sections
  # in the model.
  def field_from_content_model(content_model, section, field_name)
    section_fields = content_model[section]
    section_fields.each.select { |e| (e['name'] == field_name) }.first
  end
end

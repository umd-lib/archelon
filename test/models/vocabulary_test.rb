# frozen_string_literal: true

require 'test_helper'

class VocabularyTest < ActiveSupport::TestCase
  test 'identifier must be unique' do
    v1 = Vocabulary.new(identifier: 'foo')
    assert v1.save
    v2 = Vocabulary.new(identifier: 'foo')
    assert_not v2.save
    v3 = Vocabulary.new(identifier: 'bar')
    assert v3.save
  end
end

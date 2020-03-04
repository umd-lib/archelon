# frozen_string_literal: true

require 'test_helper'

class TypeTest < ActiveSupport::TestCase
  test 'identifier must be unique within vocabulary' do
    v1 = Vocabulary.new(identifier: 'vocab1')
    v2 = Vocabulary.new(identifier: 'vocab2')
    t1 = Type.new(identifier: 'Foo', vocabulary: v1)
    assert t1.save
    t2 = Type.new(identifier: 'Foo', vocabulary: v1)
    assert_not t2.save
    t3 = Type.new(identifier: 'Foo', vocabulary: v2)
    assert t3.save
  end
end

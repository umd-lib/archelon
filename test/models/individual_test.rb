# frozen_string_literal: true

require 'test_helper'

class IndividualTest < ActiveSupport::TestCase
  test 'identifier must be unique within vocabulary' do
    v1 = Vocabulary.new(identifier: 'vocab1')
    v2 = Vocabulary.new(identifier: 'vocab2')
    i1 = Individual.new(identifier: 'foo', label: 'Foo', vocabulary: v1)
    assert i1.save
    i2 = Individual.new(identifier: 'foo', label: 'Foo Number 2', vocabulary: v1)
    assert_not i2.save
    i3 = Individual.new(identifier: 'foo', label: 'Foo', vocabulary: v2)
    assert i3.save
  end
end

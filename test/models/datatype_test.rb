# frozen_string_literal: true

require 'test_helper'

class DatatypeTest < ActiveSupport::TestCase
  test 'identifier must be unique within vocabulary' do
    v1 = Vocabulary.new(identifier: 'vocab1')
    v2 = Vocabulary.new(identifier: 'vocab2')
    dt1 = Datatype.new(identifier: 'Foo', vocabulary: v1)
    assert dt1.save
    dt2 = Datatype.new(identifier: 'Foo', vocabulary: v1)
    assert_not dt2.save
    dt3 = Datatype.new(identifier: 'Foo', vocabulary: v2)
    assert dt3.save
  end
end

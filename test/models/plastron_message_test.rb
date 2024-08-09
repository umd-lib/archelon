# frozen_string_literal: true

require 'test_helper'
require 'test_stomp_message_helper'

class PlastronMessageTest < ActiveSupport::TestCase
  test 'parse_errors handles message with no errors' do
    resource_id = 'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2/5f/e6/54/fb/5fe654fb-5fd7-4634-8be9-a73dd51bee80'
    stomp_message = create_stomp_message_with_no_errors(resource_id)

    response = PlastronMessage.new(stomp_message)
    errors = response.parse_errors(resource_id)

    assert_equal [], errors
  end

  test 'parse_errors handles messsage with single validation error' do
    resource_id = 'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2/5f/e6/54/fb/5fe654fb-5fd7-4634-8be9-a73dd51bee80'
    stomp_message = create_stomp_message_with_validation_error(resource_id)

    response = PlastronMessage.new(stomp_message)
    errors = response.parse_errors(resource_id)

    assert_equal [{ name: 'title', status: 'failed', rule: 'required', expected: 'True' }], errors
  end

  test 'parse_errors handles messsage with single "other" error' do
    resource_id = 'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2/5f/e6/54/fb/5fe654fb-5fd7-4634-8be9-a73dd51bee80'
    stomp_message = create_stomp_message_with_other_error(resource_id)

    response = PlastronMessage.new(stomp_message)
    errors = response.parse_errors(resource_id)

    assert_equal [{ error: 'Some other error' }], errors
  end
end

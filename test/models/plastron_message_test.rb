# frozen_string_literal: true

require 'test_helper'

class PlastronMessageTest < ActiveSupport::TestCase
  test 'parse_errors handles message with no errors' do
    id = 'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2/5f/e6/54/fb/5fe654fb-5fd7-4634-8be9-a73dd51bee80'
    stomp_message = Stomp::Message.new('')
    stomp_message.headers = {
      PlastronJobId: 'SYNCHRONOUS-435eba11-3287-4f98-9225-afe50dfcc685',
      PlastronJobState: 'update_complete'
    }
    stomp_message.body =
      "{\"type\": \"update_complete\", \"stats\": {\"updated\": [\"#{id}\"], \"invalid\": {}, \"errors\": {}}}"

    response = PlastronMessage.new(stomp_message)
    errors = response.parse_errors(id)

    assert_equal [], errors
  end

  test 'parse_errors handles messsage with single validation error' do
    id = 'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2/5f/e6/54/fb/5fe654fb-5fd7-4634-8be9-a73dd51bee80'
    stomp_message = Stomp::Message.new('')
    stomp_message.headers = {
      PlastronJobId: 'SYNCHRONOUS-889ad310-f796-43f2-8608-be3b56907414',
      PlastronJobState: 'update_incomplete'
    }
    stomp_message.body =
      "{\"type\": \"update_incomplete\", \"stats\": {\"updated\": [], \"invalid\": {\"#{id}\": [\"('title', 'failed', 'required', True)\"]}, \"errors\": {}}}"

    response = PlastronMessage.new(stomp_message)
    errors = response.parse_errors(id)

    assert_equal [{ name: 'title', status: ' failed', rule: ' required', expected: ' True' }], errors
  end

  test 'parse_errors handles messsage with single "other" error' do
    id = 'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2/5f/e6/54/fb/5fe654fb-5fd7-4634-8be9-a73dd51bee80'
    stomp_message = Stomp::Message.new('')
    stomp_message.headers = {
      PlastronJobId: 'SYNCHRONOUS-889ad310-f796-43f2-8608-be3b56907414',
      PlastronJobState: 'update_incomplete'
    }
    stomp_message.body =
      "{\"type\": \"update_incomplete\", \"stats\": {\"updated\": [], \"invalid\": {}, \"errors\": {\"#{id}\": \"Some other error\"}}}"

    response = PlastronMessage.new(stomp_message)
    errors = response.parse_errors(id)

    assert_equal [{ error: 'Some other error' }], errors
  end
end

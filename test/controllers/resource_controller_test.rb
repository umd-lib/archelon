# frozen_string_literal: true

require 'test_helper'

class ResourceControllerTest < ActionController::TestCase
  setup do
    @cas_user = cas_users(:one)
    mock_cas_login(@cas_user.cas_directory_id)
  end

  test 'update should complete when SPARQL query is empty' do
    resource_id = 'http://example.com/123'
    ResourceService.should_receive(:resource_with_model).and_return({})

    post :update, params: { id: resource_id, insert: [], delete: [] }

    assert_equal(I18n.t('resource_update_successful'), flash[:notice])
    json_response = JSON.parse(response.body)
    assert_equal 'update_complete', json_response['state']
  end

  test 'update should complete when valid update processed' do
    resource_id = 'http://example.com/123'
    stomp_message = create_stomp_message_with_no_errors(resource_id)

    StompService.should_receive(:synchronous_message).and_return(stomp_message)
    ResourceService.should_receive(:resource_with_model).and_return({})
    post :update, params: { id: resource_id, insert: ["<plain_literal> <title> \"Lorem ipsum\"@en .\r\n"] }

    assert_equal(I18n.t('resource_update_successful'), flash[:notice])
    json_response = JSON.parse(response.body)
    assert_equal 'update_complete', json_response['state']
  end

  test 'update should display validation errors from STOMP message' do
    resource_id = 'http://example.com/123'
    stomp_message = create_stomp_message_with_validation_error(resource_id)

    StompService.should_receive(:synchronous_message).and_return(stomp_message)
    ResourceService.should_receive(:resource_with_model).and_return({})

    post :update, params: { id: resource_id, insert: ["<plain_literal> <title> \"Lorem ipsum\"@en .\r\n"] }

    assert_equal [{ name: 'title', status: 'failed', rule: 'required', expected: 'True' }], assigns(:errors)
  end

  test 'update should display other errors from STOMP message' do
    resource_id = 'http://example.com/123'
    stomp_message = create_stomp_message_with_other_error(resource_id)

    StompService.should_receive(:synchronous_message).and_return(stomp_message)
    ResourceService.should_receive(:resource_with_model).and_return({})

    post :update, params: { id: resource_id, insert: ["<plain_literal> <title> \"Lorem ipsum\"@en .\r\n"] }

    assert_equal [{ error: 'Some other error' }], assigns(:errors)
  end

  test 'update should display error message when MessagingError raised' do
    resource_id = 'http://example.com/123'
    messaging_error = MessagingError.new('Plastron timed out')
    StompService.should_receive(:synchronous_message).and_raise(messaging_error)
    ResourceService.should_receive(:resource_with_model).and_return({})

    post :update, params: { id: resource_id, insert: ["<plain_literal> <title> \"Lorem ipsum\"@en .\r\n"] }

    assert_equal [{ error: 'Plastron timed out' }], assigns(:errors)
  end

  def create_stomp_message_with_no_errors(resource_id)
    stomp_message = Stomp::Message.new('')
    stomp_message.headers = {
      PlastronJobId: 'SYNCHRONOUS-435eba11-3287-4f98-9225-afe50dfcc685',
      PlastronJobState: 'update_complete'
    }
    stomp_message.body =
      "{\"type\": \"update_complete\", \"stats\": {\"updated\": [\"#{resource_id}\"], \"invalid\": {}, \"errors\": {}}}"

    stomp_message
  end

  def create_stomp_message_with_validation_error(resource_id)
    stomp_message = Stomp::Message.new('')
    stomp_message.headers = {
      PlastronJobId: 'SYNCHRONOUS-889ad310-f796-43f2-8608-be3b56907414',
      PlastronJobState: 'update_incomplete'
    }
    stomp_message.body =
      "{\"type\": \"update_incomplete\", \"stats\": {\"updated\": [], \"invalid\": {\"#{resource_id}\": [\"('title', 'failed', 'required', True)\"]}, \"errors\": {}}}"

    stomp_message
  end

  def create_stomp_message_with_other_error(resource_id)
    stomp_message = Stomp::Message.new('')
    stomp_message.headers = {
      PlastronJobId: 'SYNCHRONOUS-889ad310-f796-43f2-8608-be3b56907414',
      PlastronJobState: 'update_incomplete'
    }
    stomp_message.body =
      "{\"type\": \"update_incomplete\", \"stats\": {\"updated\": [], \"invalid\": {}, \"errors\": {\"#{resource_id}\": \"Some other error\"}}}"

    stomp_message
  end
end

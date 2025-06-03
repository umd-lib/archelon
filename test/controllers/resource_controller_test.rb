# frozen_string_literal: true

require 'test_helper'
require 'test_stomp_message_helper'

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
    json_response = response.parsed_body
    assert_equal 'update_complete', json_response['state']
  end

  test 'update should complete when valid update processed' do
    skip('TODO: set up correct test environment')
    resource_id = 'http://example.com/fcrepo/foo'
    ResourceService.should_receive(:resource_with_model).and_return({})

    stub_request(:patch, 'http://localhost:5000/resources/foo?model=Item').with(
      body: "DELETE {\n } INSERT {\n<plain_literal> <title> \"Lorem ipsum\"@en .\r\n } WHERE {}",
      headers: {
        'Connection' => 'close',
        'Content-Type' => 'application/sparql-update',
        'Host' => 'localhost:5000',
        'User-Agent' => 'http.rb/5.2.0'
      }
    ).to_return(status: 204, headers: {}, body: '')

    post :update, params: { id: resource_id, insert: ["<plain_literal> <title> \"Lorem ipsum\"@en .\r\n"] }

    assert_equal(I18n.t('resource_update_successful'), flash[:notice])
    json_response = response.parsed_body
    assert_equal 'update_complete', json_response['state']
  end

  test 'update should display validation errors' do
    skip('TODO: set up correct test environment')
    resource_id = 'http://example.com/fcrepo/foo'
    ResourceService.should_receive(:resource_with_model).and_return({})

    stub_request(:patch, 'http://localhost:5000/resources/foo?model=Item').with(
      body: "DELETE {\n } INSERT {\n<plain_literal> <title> \"Lorem ipsum\"@en .\r\n } WHERE {}",
      headers: {
        'Connection' => 'close',
        'Content-Type' => 'application/sparql-update',
        'Host' => 'localhost:5000',
        'User-Agent' => 'http.rb/5.2.0'
      }
    ).to_return(
      status: 400,
      headers: {
        'Content-Type' => 'application/problem+json'
      },
      body: {
        'status' => 400,
        'title' => 'Content-model validation failed',
        'details' => '1 validation error(s) prevented update of http://example.com/fcrepo/foo with content-model Item'
      }.to_json
    )

    post :update, params: { id: resource_id, insert: ["<plain_literal> <title> \"Lorem ipsum\"@en .\r\n"] }

    assert_equal [{ name: 'title', status: 'failed', rule: 'required', expected: 'True' }], assigns(:errors)
  end
end

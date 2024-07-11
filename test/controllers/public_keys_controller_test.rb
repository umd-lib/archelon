# frozen_string_literal: true

require 'test_helper'

class PublicKeysControllerTest < ActionDispatch::IntegrationTest
  setup do
    @index_url = url_for(controller: :public_keys, action: :index)
  end

  test 'should get index' do
    get @index_url
    assert_response :success
  end

  test 'should be plain text' do
    get @index_url
    assert_equal 'text/plain; charset=utf-8', @response.header['Content-Type']
  end

  test 'should contain RSA keys' do
    get @index_url
    @response.body.split("\n").each do |line|
      assert_match(/^ssh-rsa /, line)
    end
  end
end

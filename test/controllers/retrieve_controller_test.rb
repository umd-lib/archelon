# frozen_string_literal: true

require 'test_helper'

class RetrieveControllerTest < ActionController::TestCase
  def setup
    # RetrieveController actions should not require authentication
    session[:cas_user] = nil
  end

  test 'should get retrieve' do
    download_url = download_urls(:one)
    get :retrieve, params: { token: download_url.token }
    assert_response :success
  end

  test '"retrieve" action should display disabled page if download_url is not enabled' do
    download_url = download_urls(:one)
    download_url.enabled = false
    download_url.save!

    get :retrieve, params: { token: download_url.token }
    assert_template 'disabled'
    assert_template 'retrieve'
    assert_response 410 # HTTP "Gone" status
  end

  test '"retrieve" action should display expired page if download_url is expired' do
    download_url = download_urls(:one)
    download_url.expires_at = 1.day.ago
    download_url.save!

    get :retrieve, params: { token: download_url.token }
    assert_template 'expired'
    assert_template 'retrieve'
    assert_response 410 # HTTP "Gone" status
  end

  test '"do_retrieve" action should display disabled page if download_url is not enabled' do
    download_url = download_urls(:one)
    download_url.enabled = false
    download_url.save!

    stub_network do
      get :do_retrieve, params: { token: download_url.token }
    end

    assert_template 'disabled'
    assert_template 'retrieve'
    assert_response 410 # HTTP "Gone" status
  end

  test '"do_retrieve" action should display expired page if download_url is expired' do
    download_url = download_urls(:one)
    download_url.expires_at = 1.day.ago
    download_url.save!

    stub_network do
      get :do_retrieve, params: { token: download_url.token }
    end

    assert_template 'expired'
    assert_template 'retrieve'
    assert_response 410 # HTTP "Gone" status
  end

  test 'download_url should be disabled after access' do
    download_url = download_urls(:one)
    assert download_url.enabled?

    stub_network do
      get :do_retrieve, params: { token: download_url.token }
    end

    download_url.reload
    refute download_url.enabled?
  end

  test '"do_retrieve" action should disable download_url if download_url is expired' do
    download_url = download_urls(:one)
    download_url.expires_at = 1.day.ago
    download_url.enabled = true
    download_url.save!

    stub_network do
      get :do_retrieve, params: { token: download_url.token }
    end

    assert_template 'expired'
    assert_template 'retrieve'
    assert_response 410 # HTTP "Gone" status
    download_url.reload
    refute download_url.enabled?
  end

  def teardown
    mock_cas_login(DEFAULT_TEST_USER)
  end

  private

    # Stubs the HTTP.get call, so that it won't actually make a network
    # call. Returns an HTTP:Response with a body of an empty String.
    #
    # Usage:
    #
    # stub_network do
    #   <Code that calls "get">
    # end
    def stub_network
      stub_response = HTTP::Response.new(
        version: 'HTTP/1.1',
        uri: URI('https://example.com').to_s,
        status: '200',
        body: ''
      )

      HTTP.stub :get, stub_response do
        yield
      end
    end
end

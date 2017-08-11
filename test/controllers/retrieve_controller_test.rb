require 'test_helper'

class RetrieveControllerTest < ActionController::TestCase
  def setup
    # RetreiveController actions should not require authentication
    CASClient::Frameworks::Rails::Filter.fake(nil)
  end

  test 'should get retrieve' do
    download_url = download_urls(:one)
    get :retrieve, token: download_url.token
    assert_response :success
  end

  test '"retrieve" action should display disabled page if download_url is not enabled' do
    download_url = download_urls(:one)
    download_url.enabled = false
    download_url.save!

    get :retrieve, token: download_url.token
    assert_template 'disabled'
  end

  test '"retrieve" action should display expired page if download_url is expired' do
    download_url = download_urls(:one)
    download_url.expires_at = 1.day.ago
    download_url.save!

    get :retrieve, token: download_url.token
    assert_template 'expired'
  end

  test '"do_retrieve" action should display disabled page if download_url is not enabled' do
    download_url = download_urls(:one)
    download_url.enabled = false
    download_url.save!

    mock_network do
      get :do_retrieve, token: download_url.token
    end

    assert_template 'disabled'
  end

  test '"do_retrieve" action should display expired page if download_url is expired' do
    download_url = download_urls(:one)
    download_url.expires_at = 1.day.ago
    download_url.save!

    mock_network do
      get :do_retrieve, token: download_url.token
    end

    assert_template 'expired'
  end

  test 'download_url should be disabled after access' do
    download_url = download_urls(:one)
    assert download_url.enabled?

    mock_network do
      get :do_retrieve, token: download_url.token
    end

    download_url.reload
    refute download_url.enabled?
  end

  test '"do_retrieve" action should disable download_url if download_url is expired' do
    download_url = download_urls(:one)
    download_url.expires_at = 1.day.ago
    download_url.enabled = true
    download_url.save!

    mock_network do
      get :do_retrieve, token: download_url.token
    end

    assert_template 'expired'
    download_url.reload
    refute download_url.enabled?
  end

  def teardown
    CASClient::Frameworks::Rails::Filter.fake(DEFAULT_TEST_USER)
  end

  private

    # Mocks the Kernel.open call, so that it won't actually make a network
    # call. Returns an empty String.
    #
    # Usage:
    #
    # mock_network do
    #   <Code that calls "open">
    # end
    def mock_network
      mock = Minitest::Mock.new
      def mock.read
      end

      Kernel.stub :open, '', mock do
        yield
      end
    end
end

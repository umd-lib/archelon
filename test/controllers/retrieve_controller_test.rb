require 'test_helper'

class RetrieveControllerTest < ActionController::TestCase
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

    # Create mock to handle block for OpenURI.open method
    #mock = Minitest::Mock.new
    # def mock.read
    # end

    # OpenURI.stub :open, '', mock do
    #   get :do_retrieve, token: download_url.token
    # end

    mock_network do
      get :do_retrieve, token: download_url.token
    end

    download_url.reload
    refute download_url.enabled?
  end

  private

    def mock_network
      mock = Minitest::Mock.new
      def mock.read
      end

      OpenURI.stub :open, '', mock do
        yield
      end
    end

end

require 'test_helper'

class RetrieveControllerTest < ActionController::TestCase
  test 'should get retrieve' do
    download_url = download_urls(:one)
    get :retrieve, token: download_url.token
    assert_response :success
  end

  test 'should display disabled page if download_url is not enabled' do
    download_url = download_urls(:one)
    download_url.enabled = false
    download_url.save!

    get :retrieve, token: download_url.token
    assert_template 'disabled'
  end

  test 'download_url should be disabled after access' do
    download_url = download_urls(:one)
    assert download_url.enabled?

    # Create mock to handle block for OpenURI.open method
    mock = Minitest::Mock.new
    def mock.read
    end

    OpenURI.stub :open, '', mock do
      get :do_retrieve, token: download_url.token
    end

    download_url.reload
    refute download_url.enabled?
  end

end

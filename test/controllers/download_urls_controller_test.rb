require 'test_helper'

class DownloadUrlsControllerTest < ActionController::TestCase
  setup do
    @download_url = download_urls(:one)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:download_urls)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create download_url' do
    assert_difference('DownloadUrl.count') do
      post :create, download_url: {
        accessed_at: @download_url.accessed_at,
        download_completed_at: @download_url.download_completed_at,
        enabled: @download_url.enabled, mimetype: @download_url.mimetype,
        notes: @download_url.notes, request_ip: @download_url.request_ip,
        request_user_agent: @download_url.request_user_agent,
        title: @download_url.title,
        url: @download_url.url
      }
    end

    assert_redirected_to download_url_path(assigns(:download_url))
  end

  test 'should add creator on create' do
    assert_difference('DownloadUrl.count') do
      post :create, download_url: {
        accessed_at: @download_url.accessed_at,
        download_completed_at: @download_url.download_completed_at,
        enabled: @download_url.enabled, mimetype: @download_url.mimetype,
        notes: @download_url.notes, request_ip: @download_url.request_ip,
        request_user_agent: @download_url.request_user_agent,
        title: @download_url.title,
        url: @download_url.url
      }
    end
    download_url = DownloadUrl.last
    assert_equal session[:cas_user], download_url.creator
  end

  test 'should not be able to set token or creator on create' do
    token_to_try = '12345'
    creator_to_try = 'one'
    assert_difference('DownloadUrl.count') do
      post :create, download_url: {
        accessed_at: @download_url.accessed_at,
        download_completed_at: @download_url.download_completed_at,
        enabled: @download_url.enabled, mimetype: @download_url.mimetype,
        notes: @download_url.notes, request_ip: @download_url.request_ip,
        request_user_agent: @download_url.request_user_agent,
        title: @download_url.title,
        url: @download_url.url, token: token_to_try, creator: creator_to_try
      }
    end
    download_url = DownloadUrl.last
    assert_not_equal token_to_try, download_url.token
    assert_not_equal creator_to_try, download_url.creator
  end

  test 'should require a note on create' do
    assert_no_difference('DownloadUrl.count') do
      post :create, download_url: {
        accessed_at: @download_url.accessed_at,
        download_completed_at: @download_url.download_completed_at,
        enabled: @download_url.enabled, mimetype: @download_url.mimetype,
        notes: nil, request_ip: @download_url.request_ip,
        request_user_agent: @download_url.request_user_agent,
        title: @download_url.title,
        url: @download_url.url
      }
    end
  end

  test 'should show download_url' do
    get :show, id: @download_url
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @download_url
    assert_response :success
  end

  test 'should update download_url' do
    patch :update, id: @download_url, download_url: {
      accessed_at: @download_url.accessed_at, creator: @download_url.creator,
      download_completed_at: @download_url.download_completed_at,
      enabled: @download_url.enabled, mimetype: @download_url.mimetype,
      notes: @download_url.notes, request_ip: @download_url.request_ip,
      request_user_agent: @download_url.request_user_agent,
      title: @download_url.title, token: @download_url.token,
      url: @download_url.url
    }
    assert_redirected_to download_url_path(assigns(:download_url))
  end

  test 'should destroy download_url' do
    assert_difference('DownloadUrl.count', -1) do
      delete :destroy, id: @download_url
    end

    assert_redirected_to download_urls_path
  end

  test 'generate_download_url should raise 404 RoutingError if document cannot be found' do
    assert_raises(ActionController::RoutingError) do
      get :generate_download_url, document_url: 'document does not exist'
    end
  end

  test 'create_download_url should raise 404 RoutingError if document cannot be found' do
    assert_raises(ActionController::RoutingError) do
      get :create_download_url, document_url: 'document does not exist'
    end
  end
end

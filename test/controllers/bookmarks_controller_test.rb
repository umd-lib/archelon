# frozen_string_literal: true

require 'test_helper'

class BookmarksControllerTest < ActionController::TestCase
  setup do
    @cas_user = cas_users(:one)
    mock_cas_login(@cas_user.cas_directory_id)
    @cas_user.bookmarks.create(document_id: 'http://fcrepo-test/123', document_type: SolrDocument)
  end

  test 'should not create second bookmark if max bookmark limit reached' do
    @controller.stub(:max_limit, 1) do
      put :update, xhr: true, params: { id: 'http://fcrepo-test/new', format: :js }
      assert_response :forbidden
    end
  end

  test 'should create second bookmark if within max bookmark limit' do
    @controller.stub(:max_limit, 2) do
      put :update, xhr: true, params: { id: 'http://fcrepo-test/new', format: :js }
      assert_response :success
    end
  end
end

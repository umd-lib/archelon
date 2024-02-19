require 'test_helper'

class PublishJobControllerTest < ActionController::TestCase
  setup do
    @cas_user = cas_users(:test_admin)
    mock_cas_login(@cas_user.cas_directory_id)
  end

test "Users should see all jobs on the index page" do
    assert PublishJob.count.positive?, 'Test requires at least one publish job'

    get :index
    jobs = assigns(:jobs)
    assert_equal PublishJob.count, jobs.count
  end
end

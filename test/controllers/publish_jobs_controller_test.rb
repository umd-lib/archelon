# frozen_string_literal: true

require 'test_helper'

# frozen_string_literal: true
class PublishJobsControllerTest < ActionController::TestCase
  setup do
    @cas_user = cas_users(:test_admin)
    mock_cas_login(@cas_user.cas_directory_id)
  end

  test 'non-Admin users should only see their own jobs on the index page' do
    assert PublishJob.count > 1, 'Test requires at least two publish jobs'

    @cas_user = cas_users(:test_user)
    mock_cas_login(@cas_user.cas_directory_id)

    # Set up an publish job for the user
    publish_job = PublishJob.first
    publish_job.cas_user = @cas_user
    publish_job.solr_ids = %w[foobar testcase]
    publish_job.publish = true
    publish_job.state = 1
    publish_job.save!

    assert @cas_user.user?, 'Test requires a non-admin user'

    get :index
    jobs = assigns(:jobs)
    assert jobs.count.positive?, 'User must have at least one publish job.'
    assert jobs.count < PublishJob.count, 'There must be some jobs not belonging to user.'
    jobs.each do |j|
      assert_equal @cas_user, j.cas_user
    end
  end

  test 'admin users should see all jobs on the index page' do
    assert PublishJob.count.positive?, 'Test requires at least one publish job'
    assert @cas_user.admin?, 'Test requires an admin user'

    get :index
    jobs = assigns(:jobs)
    assert_equal PublishJob.count, jobs.count
  end

  test 'assert valid results when viewing a job' do
    assert PublishJob.count.positive?, 'Test requires at least one publish job'

    # Set up an publish job for the user
    publish_job = PublishJob.first
    publish_job.cas_user = @cas_user
    publish_job.solr_ids = %w[foobar testcase]
    publish_job.publish = true
    publish_job.state = 1
    publish_job.save!

    Blacklight::SearchService.any_instance.stub(:fetch).and_return(SolrDocument.new)
    get :show, params: { id: PublishJob.first.id }

    job = assigns(:job)
    hidden = assigns(:hidden)
    published = assigns(:published)
    unpublished = assigns(:unpublished)
    result_documents = assigns(:result_documents)

    assert_equal job.cas_user.cas_directory_id, @cas_user.cas_directory_id
    assert job.publish == true
    assert_equal job.state, 'publish_not_submitted'
    assert_equal hidden, 0
    assert_equal published, 0
    assert_equal unpublished, 2
    assert_equal result_documents.length, 2
  end
end

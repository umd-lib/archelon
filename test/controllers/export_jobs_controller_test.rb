# frozen_string_literal: true

require 'test_helper'

class ExportJobsControllerTest < ActionController::TestCase
  setup do
    @cas_user = cas_users(:test_admin)
    mock_cas_login(@cas_user.cas_directory_id)
  end

  test 'create new export job' do
    stub_const('StompService', double('stomp_service_connected', publish_message: true))
    expect(StompService).to receive(:publish_message)

    assert_difference('ExportJob.count') do
      @cas_user.bookmarks.create(document_id: 'http://example.com/1', document_type: 'SolrDocument')
      @cas_user.bookmarks.create(document_id: 'http://example.com/2', document_type: 'SolrDocument')
      params = {}
      params[:export_job] = { name: 'test1', format: 'CSV', item_count: 2 }

      post :create, params: params
    end
    export_job = ExportJob.last
    assert export_job.plastron_status_in_progress?

    assert_redirected_to export_jobs_path
    @cas_user.bookmarks.delete_all
  end

  test 'creating new export job when not connected should raise error' do
    stub_const('StompService', double('stomp_service_disconnected', publish_message: false))
    expect(StompService).to receive(:publish_message)

    assert_difference('ExportJob.count') do
      @cas_user.bookmarks.create(document_id: 'http://example.com/1', document_type: 'SolrDocument')
      @cas_user.bookmarks.create(document_id: 'http://example.com/2', document_type: 'SolrDocument')
      params = {}
      params[:export_job] = { name: 'test1', format: 'CSV', item_count: 2 }

      post :create, params: params
    end
    export_job = ExportJob.last
    assert export_job.plastron_status_error?

    assert_equal I18n.t(:active_mq_is_down), flash[:error]
    assert_redirected_to export_jobs_path
    @cas_user.bookmarks.delete_all
  end

  test "index page should show only user's jobs when user is not an admin" do
    assert ExportJob.count > 1, 'Test requires at least two export jobs'

    @cas_user = cas_users(:test_user)
    mock_cas_login(@cas_user.cas_directory_id)

    # Set up an export job for the user
    export_job = ExportJob.first
    export_job.cas_user = @cas_user
    export_job.save!

    assert @cas_user.user?, 'Test requires a non-admin user'

    get :index
    jobs = assigns(:jobs)
    assert jobs.count.positive?, 'User must have at least one export job.'
    assert jobs.count < ExportJob.count, 'There must be some jobs not belonging to user.'
    jobs.each do |j|
      assert_equal @cas_user, j.cas_user
    end
  end

  test 'index page should show all jobs when user is an admin' do
    assert ExportJob.count.positive?, 'Test requires at least one export job'
    assert @cas_user.admin?, 'Test requires an admin user'

    get :index
    jobs = assigns(:jobs)
    assert_equal ExportJob.count, jobs.count
  end

  test 'download can only be done by export job owner or admin' do
    export_job = export_jobs(:one)

    export_job_owner = export_job.cas_user
    ability = Ability.new(export_job_owner)
    assert ability.can?(:download, export_job)

    admin_user = cas_users(:test_admin)
    ability = Ability.new(admin_user)
    assert ability.can?(:download, export_job)

    invalid_user = cas_users(:two)
    assert_not_equal export_job.cas_user, invalid_user
    ability = Ability.new(invalid_user)
    assert ability.cannot?(:download, export_job)
  end

  test 'review allows submission when no binaries download' do
    ExportJobsController.any_instance.stub(:selected_items?).and_return(true)
    params = {}
    params[:export_job] = { name: 'test', format: 'CSV', item_count: 2, export_binaries: false }
    get :review, params: params
    assert_template :review
  end

  test 'review allows submission when binaries file size is less than or equal to maximum' do
    export_job = export_jobs(:one)

    max_size = export_job.max_allowed_binaries_download_size
    ExportJobsController.any_instance.stub(:selected_items?).and_return(true)
    BinariesStats.stub(:get_stats, count: 1, total_size: max_size) do
      params = {}
      params[:export_job] = { name: 'test', format: 'CSV', item_count: 2, export_binaries: true }
      get :review, params: params
      assert_template :review
    end
  end

  test 'review denies submission when binaries file size is greater than maximum' do
    export_job = export_jobs(:one)

    max_size = export_job.max_allowed_binaries_download_size
    too_large = max_size + 1
    ExportJobsController.any_instance.stub(:selected_items?).and_return(true)
    BinariesStats.stub(:get_stats, count: 1, total_size: too_large) do
      params = {}
      params[:export_job] = { name: 'test', format: 'CSV', item_count: 2, export_binaries: true }
      get :review, params: params
      assert_template :job_submission_not_allowed
    end
  end

  test 'create not allowed when when binaries file size is greater than maximum' do
    export_job = export_jobs(:one)

    max_size = export_job.max_allowed_binaries_download_size
    too_large = max_size + 1
    ExportJobsController.any_instance.stub(:selected_items?).and_return(true)
    BinariesStats.stub(:get_stats, count: 1, total_size: too_large) do
      params = {}
      params[:export_job] = { name: 'test', format: 'CSV', item_count: 2, export_binaries: true }
      post :create, params: params
      assert_template :job_submission_not_allowed
    end
  end
end

# frozen_string_literal: true

require 'test_helper'

class ImportJobsControllerTest < ActionController::TestCase
  setup do
    @cas_user = cas_users(:test_admin)
    mock_cas_login(@cas_user.cas_directory_id)

    # Stub Blacklight::Solr::Repository so that repository collections can be retrieved
    stub_repository_collections_solr_response('services/repository_collections/solr_response_one_collection.json')

    stub_request(:get, 'http://vocab.lib.umd.edu/access').to_return(status: 200, body: '', headers: {})
  end

  test 'actions should redirect to login when unauthenticated' do
    mock_cas_logout

    actions = %i[index new create]

    actions.each do |action|
      get action
      assert_redirected_to 'http://test.host/login', "Unauthenticated user not redirected to login for #{action}"
    end
  end

  test 'index page should show all jobs when user is an admin' do
    assert ImportJob.any?, 'Test requires at least one import job'
    assert @cas_user.admin?, 'Test requires an admin user'

    get :index
    import_jobs = assigns(:import_jobs)
    assert_equal ImportJob.count, import_jobs.count
  end

  test "index page should show only user's jobs when user is not an admin" do
    assert ImportJob.many?, 'Test requires at least two import jobs'

    @cas_user = cas_users(:test_user)
    mock_cas_login(@cas_user.cas_directory_id)

    # Set up an import job for the user
    import_job = ImportJob.first
    import_job.cas_user = @cas_user
    import_job.save!

    assert @cas_user.user?, 'Test requires a non-admin user'

    get :index
    import_jobs = assigns(:import_jobs)
    assert import_jobs.any?, 'User must have at least one import job.'
    assert import_jobs.count < ImportJob.count, 'There must be some jobs not belonging to user.'
    import_jobs.each do |j|
      assert_equal @cas_user, j.cas_user
    end
  end

  test 'should get new' do
    get :new

    new_import_job = assigns(:import_job)
    assert_not_nil new_import_job

    # Import job name should start with CAS directory id
    assert_match(/^#{@cas_user.cas_directory_id}/, new_import_job.name)
  end

  test 'should create import_job' do
    mock_stomp_connection

    name = "#{@cas_user.cas_directory_id}-#{Time.now.iso8601}"
    assert_difference('ImportJob.count') do
      post :create, params: {
        # UMD Blacklight 8 Fix
        import_job: { name: name, collection: 'http://example.com/foo/baz',
                      # fixture_file_upload paths are now relative to "fixtures/files"
                      metadata_file: fixture_file_upload('valid_import.csv') }
        # End UMD Blacklight 8 Fix
      }
    end

    assert_redirected_to import_jobs_url
  end

  test 'name is required when creating import_job' do
    name = ''
    assert_no_difference('ImportJob.count') do
      post :create, params: {
        # UMD Blacklight 8 Fix
        import_job: { name: name, collection: 'http://example.com/foo/baz',
                      # fixture_file_upload paths are now relative to "fixtures/files"
                      metadata_file: fixture_file_upload('valid_import.csv') }
        # End UMD Blacklight 8 Fix
      }
    end

    # Verify that error message is provided
    import_job = assigns(:import_job)
    assert_includes(import_job.errors.messages[:name],
                    I18n.t('errors.messages.blank'))
  end

  test 'file attachment is required when creating import_job' do
    name = "#{@cas_user.cas_directory_id}-#{Time.now.iso8601}"
    assert_no_difference('ImportJob.count') do
      post :create, params: {
        import_job: { name: name, collection: 'http://example.com/foo/baz' }
      }
    end

    # Verify that error message is provided
    import_job = assigns(:import_job)
    assert_includes(import_job.errors.messages[:metadata_file],
                    I18n.t('activerecord.errors.models.import_job.attributes.metadata_file.required'))
  end

  test 'should get show' do
    # Stub HTTP.get to handle PlastronService request
    json_fixture_file = 'services/import_job/plastron_job_detail_response.json'
    json_response = file_fixture(json_fixture_file).read
    stub_result = OpenStruct.new
    stub_result.body = json_response

    HTTP.stub :get, stub_result do
      import_job = ImportJob.first
      get :show, params: { id: import_job.id }
      assert_response :success
    end
  end

  test 'should get edit' do
    import_job = ImportJob.first
    get :edit, params: { id: import_job.id }
    assert_response :success
  end

  test 'name cannot be blank when updating import_job' do
    import_job = ImportJob.first
    patch :update, params: { id: import_job.id, import_job: { name: '' } }
    result = assigns(:import_job)
    assert_includes(result.errors.messages[:name],
                    I18n.t('errors.messages.blank'))
    assert_template :edit
  end

  test 'should not be able to edit a job that is in "import" stage' do
    import_job = ImportJob.first
    import_job.state = :import_complete
    import_job.save!
    get :edit, params: { id: import_job.id }
    assert_redirected_to import_jobs_url
    assert_equal I18n.t(:import_already_performed), flash[:error]
  end

  test 'should not be able to update a job that is in "import" stage' do
    import_job = ImportJob.first
    import_job.state = :import_complete
    import_job.save!
    # UMD Blacklight 8 Fix
    patch :update, params: { id: import_job.id,
                             # fixture_file_upload paths are now relative to "fixtures/files"
                             import_job: { name: import_job.name, metadata_file: fixture_file_upload('valid_import.csv') } }
    # End UMD Blacklight 8 Fix
    assert_redirected_to import_jobs_url
    assert_equal I18n.t(:import_already_performed), flash[:error]
  end

  test 'should not be able to import a job where the import has completed' do
    import_job = ImportJob.first
    import_job.state = :import_complete
    import_job.save!

    patch :import, params: { id: import_job.id }
    assert_redirected_to import_jobs_url
    assert_equal I18n.t(:import_already_performed), flash[:error]
  end

  test 'should not be able to import a job with validation errors' do
    import_job = ImportJob.first
    import_job.state = :validate_failed
    import_job.save!

    patch :import, params: { id: import_job.id }
    assert_redirected_to import_jobs_url
    assert_equal I18n.t(:cannot_import_invalid_file), flash[:error]
  end

  test 'status_text should show information about the current status' do # rubocop:disable Metrics/BlockLength
    tests = [
      # Validate Stages
      { state: :validate_pending, progress: 0,
        expected_text: I18n.t('activerecord.attributes.import_job.status.validate_pending') },
      { state: :validate_success, progress: 100,
        expected_text: I18n.t('activerecord.attributes.import_job.status.validate_success') },
      { state: :validate_failed, progress: 100,
        expected_text: I18n.t('activerecord.attributes.import_job.status.validate_failed') },

      # Import Stages
      { state: :import_pending, progress: 0,
        expected_text: I18n.t('activerecord.attributes.import_job.status.import_pending') },
      { state: :import_complete, progress: 100,
        expected_text: I18n.t('activerecord.attributes.import_job.status.import_complete') },
      { state: :import_incomplete, progress: 100,
        expected_text: I18n.t('activerecord.attributes.import_job.status.import_incomplete') },

      # Error
      { state: :validate_error, progress: 0,
        expected_text: I18n.t('activerecord.attributes.import_job.status.validate_error') },
      { state: :import_error, progress: 0,
        expected_text: I18n.t('activerecord.attributes.import_job.status.import_error') },

      # In Progress (with non-zero percentage)
      { state: :import_in_progress, progress: 20,
        expected_text: "#{I18n.t('activerecord.attributes.import_job.status.import_in_progress')} (20%)" },

      # In Progress (zero percentage)
      { state: :import_in_progress, progress: 0,
        expected_text: I18n.t('activerecord.attributes.import_job.status.import_in_progress') },
      { state: :import_in_progress, progress: 0,
        expected_text: I18n.t('activerecord.attributes.import_job.status.import_in_progress') }
    ]

    tests.each do |test|
      import_job = ImportJob.first
      import_job.state = test[:state]
      import_job.progress = test[:progress]
      status_text = @controller.status_text(import_job)
      assert_equal test[:expected_text], status_text, "Failed for #{test[:state]}, #{test[:progress]}"
    end
  end

  test 'flash message should be displayed when Solr is down' do
    Blacklight::Solr::Repository.any_instance.stub(:search).and_return(StandardError.new)
    get :new

    collections_options_array = assigns(:collections_options_array)

    assert_equal I18n.t(:solr_is_down), flash[:error]
    assert_equal [], collections_options_array
  end
end

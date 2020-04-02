require 'test_helper'

class ImportJobsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @import_job = import_jobs(:one)
  end

  test "should get index" do
    get import_jobs_url
    assert_response :success
  end

  test "should get new" do
    get new_import_job_url
    assert_response :success
  end

  test "should create import_job" do
    assert_difference('ImportJob.count') do
      post import_jobs_url, params: { import_job: { cas_user_id: @import_job.cas_user_id, plastron_operation_id: @import_job.plastron_operation_id } }
    end

    assert_redirected_to import_job_url(ImportJob.last)
  end

  test "should show import_job" do
    get import_job_url(@import_job)
    assert_response :success
  end

  test "should get edit" do
    get edit_import_job_url(@import_job)
    assert_response :success
  end

  test "should update import_job" do
    patch import_job_url(@import_job), params: { import_job: { cas_user_id: @import_job.cas_user_id, plastron_operation_id: @import_job.plastron_operation_id } }
    assert_redirected_to import_job_url(@import_job)
  end

  test "should destroy import_job" do
    assert_difference('ImportJob.count', -1) do
      delete import_job_url(@import_job)
    end

    assert_redirected_to import_jobs_url
  end
end

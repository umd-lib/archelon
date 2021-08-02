# frozen_string_literal: true

require 'test_helper'

class ImportJobsChannelTest < ActionCable::Channel::TestCase
  include ActionCable::TestHelper

  test 'test_import_job_status_check should not send broadcasts when import job status is the same' do
    import_job = import_jobs(:two)

    # Using "update_columns" so we don't trigger "after_commit" hook on
    # the model and cause broadcasts
    import_job.update_columns(state: :validate_failed) # rubocop:disable Rails/SkipsModelValidations

    assert import_job.validate_failed?
    assert_not import_job.cas_user.admin?

    job_id = import_job.id.to_s
    data = { 'jobs' => [{ 'jobId' => job_id, 'state' => 'validate_failed' }] }

    user_stream = ImportJobsChannel.stream(import_job.cas_user)
    admins_stream = ImportJobsChannel.admins_stream

    stub_connection(current_user: import_job.cas_user)
    subscribe

    assert_broadcasts(admins_stream, 0) do
      assert_broadcasts(user_stream, 0) do
        perform subscription.import_job_status_check(data)
      end
    end
  end

  test 'test_import_job_status_check should send broadcasts to user and admins stream when import job status differs and user is not an admin' do
    import_job = import_jobs(:two)

    # Using "update_columns" so we don't trigger "after_commit" hook on
    # the model and cause broadcasts
    import_job.update_columns(state: :validate_failed) # rubocop:disable Rails/SkipsModelValidations

    assert import_job.validate_failed?
    assert_not import_job.cas_user.admin?

    job_id = import_job.id.to_s
    data = { 'jobs' => [{ 'jobId' => job_id, 'status' => 'validate_pending' }] }

    user_stream = ImportJobsChannel.stream(import_job.cas_user)
    admins_stream = ImportJobsChannel.admins_stream

    stub_connection(current_user: import_job.cas_user)
    subscribe

    # Import job status check will broadcast on both the user stream, and
    # the admin stream, when the user is not an admin.
    assert_broadcasts(admins_stream, 1) do
      assert_broadcasts(user_stream, 1) do
        perform subscription.import_job_status_check(data)
      end
    end
  end

  test 'test_import_job_status_check should send broadcasts only admins stream when import job status differs and user is an admin' do
    import_job = import_jobs(:test_admin_import_job)

    # Using "update_columns" so we don't trigger "after_commit" hook on
    # the model and cause broadcasts
    import_job.update_columns(state: :validate_failed) # rubocop:disable Rails/SkipsModelValidations

    assert import_job.validate_failed?
    assert import_job.cas_user.admin?

    job_id = import_job.id.to_s
    data = { 'jobs' => [{ 'jobId' => job_id, 'state' => 'validate_pending' }] }

    user_stream = ImportJobsChannel.stream(import_job.cas_user)
    admins_stream = ImportJobsChannel.admins_stream

    stub_connection(current_user: import_job.cas_user)
    subscribe

    # Import job status check will broadcast on both the user stream, and
    # the admin stream, when the user is not an admin.
    assert_broadcasts(admins_stream, 1) do
      assert_broadcasts(user_stream, 0) do
        perform subscription.import_job_status_check(data)
      end
    end
  end
end

# frozen_string_literal: true

require 'test_helper'

class ImportJobRelayJobTest < ActiveJob::TestCase
  include ActionCable::TestHelper

  test 'import jobs by non-admin users are broadcast to a user-specific channel and an admin channel' do
    import_job = import_jobs(:two)
    assert_not import_job.cas_user.admin?

    admins_channel_name = ImportJobsChannel.admins_channel_name
    user_specific_channel_name = ImportJobsChannel.channel_name(import_job.cas_user)

    assert_broadcasts(admins_channel_name, 1) do
      assert_broadcasts(user_specific_channel_name, 1) do
        ImportJobRelayJob.perform_now(import_job)
      end
    end
  end

  test 'import jobs by admin users are broadcast only to the admin channel' do
    import_job = import_jobs(:test_admin_import_job)
    assert import_job.cas_user.admin?

    admins_channel_name = ImportJobsChannel.admins_channel_name
    user_specific_channel_name = ImportJobsChannel.channel_name(import_job.cas_user)

    assert_broadcasts(admins_channel_name, 1) do
      assert_broadcasts(user_specific_channel_name, 0) do
        ImportJobRelayJob.perform_now(import_job)
      end
    end
  end
end

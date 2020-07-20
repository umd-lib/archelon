# frozen_string_literal: true

require 'test_helper'

class ExportJobRelayJobTest < ActiveJob::TestCase
  include ActionCable::TestHelper

  test 'export jobs by non-admin users are broadcast to a user-specific stream and an admin stream' do
    export_job = export_jobs(:one)
    assert_not export_job.cas_user.admin?

    admins_stream = ExportJobsChannel.admins_stream
    user_stream = ExportJobsChannel.stream(export_job.cas_user)

    assert_broadcasts(admins_stream, 1) do
      assert_broadcasts(user_stream, 1) do
        ExportJobRelayJob.perform_now(export_job)
      end
    end
  end

  test 'export jobs by admin users are broadcast only to the admin stream' do
    export_job = export_jobs(:test_admin_export_job)
    assert export_job.cas_user.admin?

    admins_stream = ExportJobsChannel.admins_stream
    user_stream = ExportJobsChannel.stream(export_job.cas_user)

    assert_broadcasts(admins_stream, 1) do
      assert_broadcasts(user_stream, 0) do
        ExportJobRelayJob.perform_now(export_job)
      end
    end
  end
end

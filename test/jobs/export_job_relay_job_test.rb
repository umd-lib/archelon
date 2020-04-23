# frozen_string_literal: true

require 'test_helper'

class ExportJobRelayJobTest < ActiveJob::TestCase
  include ActionCable::TestHelper

  test "broadcasts message to 'export_jobs:status' channel" do
    export_job = export_jobs(:one)
    channel_name = ExportJobsChannel.channel_name(export_job.cas_user)
    assert_broadcasts(channel_name, 1) do
      ExportJobRelayJob.perform_now(export_job)
    end
  end
end

# test/jobs/chat_relay_job_test.rb

require 'test_helper'

class ExportJobRelayJobTest < ActiveJob::TestCase
  include ActionCable::TestHelper

  test "broadcasts message to 'export_jobs:status' channel" do
    export_job = export_jobs(:one)
    assert_broadcasts('export_jobs:status', 1) do
      ExportJobRelayJob.perform_now(export_job)
    end
  end
end

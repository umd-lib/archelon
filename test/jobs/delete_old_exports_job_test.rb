# frozen_string_literal: true

require 'test_helper'

class DeleteOldExportsJobTest < ActiveJob::TestCase
  test 'deletes ExportJobs older than 30 days' do
    all_jobs = ExportJob.all.count
    old_jobs = ExportJob.where('created_at > ? ', 30.days.ago).count

    assert all_jobs.positive?
    DeleteOldExportsJob.perform_now
    assert_equal ExportJob.all.count, all_jobs - old_jobs
  end
end

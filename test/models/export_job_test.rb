# frozen_string_literal: true

require 'test_helper'

class ExportJobTest < ActiveSupport::TestCase
  test 'binaries download that exceeds max size are not allowed' do
    job = export_jobs(:one)
    job.export_binaries = true

    max_size = job.max_allowed_binaries_download_size
    assert_equal(50.gigabytes, max_size)

    job.binaries_size = max_size
    assert job.job_submission_allowed?

    too_large = max_size + 1
    job.binaries_size = too_large
    assert_not job.job_submission_allowed?
  end
end

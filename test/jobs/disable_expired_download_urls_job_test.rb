# frozen_string_literal: true

require 'test_helper'

class DisableExpiredDownloadUrlsJobTest < ActiveJob::TestCase
  test 'disables DownloadUrls that have passed their expiration date' do
    expired = create_download_url(7.days.ago)
    not_expired = create_download_url(21.days.from_now)

    assert expired.enabled?
    assert not_expired.enabled?

    test_date = Time.current
    DisableExpiredDownloadUrlsJob.perform_now(test_date)

    assert_not expired.reload.enabled?
    assert not_expired.reload.enabled?
  end

  def create_download_url(expiration_time)
    download_url = DownloadUrl.new
    download_url.enabled = true
    download_url.notes = "Expires at #{expiration_time}"
    download_url.expires_at = expiration_time
    download_url.save!
    download_url
  end
end

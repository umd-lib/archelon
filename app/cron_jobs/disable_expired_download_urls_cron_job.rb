# frozen_string_literal: true

# Disables expired DownloadUrls on a cron-like schedule
class DisableExpiredDownloadUrlsCronJob < CronJob
  # Run every day at 3am
  self.cron_expression = '0 3 * * *'

  # will enqueue the disable expired download urls job
  def perform
    current_time = Time.current
    DisableExpiredDownloadUrlsJob.perform_now(current_time)
  end
end

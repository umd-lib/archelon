# frozen_string_literal: true

# Deletes old export jobs on a cron-like schedule
class DeleteOldExportJobsCronJob < CronJob
  # Run every day at 4am
  self.cron_expression = '0 4 * * *'

  def perform
    DeleteOldExportsJob.perform_now
  end
end

# frozen_string_literal: true

# Deletes Export Jobs that are over 30 days old
class DeleteOldExportsJob < ApplicationJob
  queue_as :default

  def perform # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    Rails.logger.info 'Running DeleteOldExportsJob'
    export_jobs = ExportJob.where('created_at > ? ', 30.days.ago)

    if export_jobs.any?
      export_jobs.each do |job|
        Rails.logger.info("Deleting export job: #{job.name}")
        File.delete(job.path) if File.exist? job.path
        job.destroy
      end
    else
      Rails.logger.info('No export jobs to delete')
    end
  end
end

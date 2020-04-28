# frozen_string_literal: true

# Job for broadcasting import job status over Action Cable to clients
class ImportJobRelayJob < ApplicationJob
  def perform(import_job)
    # ImportJobsChannel.broadcast expects an array, so create one
    import_jobs = [import_job]

    ImportJobsChannel.broadcast(import_jobs)
  end
end

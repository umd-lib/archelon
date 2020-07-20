# frozen_string_literal: true

# Job for broadcasting export job status over Action Cable to clients
class ExportJobRelayJob < ApplicationJob
  def perform(export_job)
    ExportJobsChannel.broadcast(export_job)
  end
end

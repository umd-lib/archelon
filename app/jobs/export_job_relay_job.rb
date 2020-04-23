# frozen_string_literal: true

# Job for broadcasting export job status over Action Cable to clients
class ExportJobRelayJob < ApplicationJob
  def perform(export_job)
    channel_name = ExportJobsChannel.channel_name(export_job.cas_user)
    ActionCable.server.broadcast channel_name,
                                 export_job: export_job, message: render_message(export_job)
  end

  def render_message(export_job)
    ApplicationController.renderer.render(partial: 'export_jobs/export_job_status', locals: { export_job: export_job })
  end
end

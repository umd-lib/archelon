# frozen_string_literal: true

# Job for broadcasting export job status over Action Cable to clients
class ExportJobStatusUpdatedJob < ApplicationJob
  retry_on RuntimeError

  def perform(export_job)
    ExportJobsChannel.broadcast_to(export_job, job: export_job, statusWidget: status_widget(export_job))
  end

  private

    def status_widget(export_job)
      ActionController::Renderer.for(ExportJobsController).render(
        partial: 'export_job_status',
        locals: { export_job: export_job }
      )
    end
end

# frozen_string_literal: true

# Job for broadcasting import job status over Action Cable to clients
class ImportJobStatusUpdatedJob < ApplicationJob
  retry_on RuntimeError

  def perform(import_job)
    Rails.logger.debug {
      "Broadcasting ImportJob #{import_job.id} to ImportJobsChannel, " \
        "status=#{import_job.state}, progress=#{import_job.progress_text}"
    }
    ImportJobsChannel.broadcast_to(import_job, job: import_job, statusWidget: status_widget(import_job))
  end

  private

    def status_widget(import_job)
      ActionController::Renderer.for(ImportJobsController).render(
        partial: 'import_job_status',
        locals: { import_job: import_job }
      )
    end
end

# frozen_string_literal: true

# Job for broadcasting publish job status over Action Cable to clients
class PublishJobStatusUpdatedJob < ApplicationJob
  retry_on RuntimeError

  def perform(publish_job)
    Rails.logger.debug {
      "Broadcasting PublishJob #{publish_job.id} to PublishJobsChannel, " \
      "status=#{publish_job.state}, progress=#{publish_job.progress_text}"
    }
    PublishJobsChannel.broadcast_to(publish_job, job: publish_job, statusWidget: status_widget(publish_job))
  end

  private

    def status_widget(publish_job)
      ActionController::Renderer.for(PublishJobsController).render(
        partial: 'publish_job_status',
        locals: { publish_job: publish_job }
      )
    end
end

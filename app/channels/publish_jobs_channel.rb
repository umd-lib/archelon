class PublishJobsChannel < ApplicationCable::Channel
  def subscribed
    publish_job = PublishJob.find(params[:id])
    username = current_user.cas_directory_id
    Rails.logger.debug("Received subscription for PublishJob #{publish_job.id} from user #{username}")
    stream_for publish_job if authorized_to_stream publish_job
  end

  def publish_job_status_check(data)
    job_id = data['jobId']
    publish_job = PublishJob.find(job_id)
    return if publish_job.nil?

    PublishJobStatusUpdatedJob.perform_now(publish_job)
  end

  private

    def username
      current_user.cas_directory_id
    end

    # confirm that the current user should be able to subscribe to this publish job
    def authorized_to_stream(publish_job)
      if current_user.admin? || publish_job.cas_user == current_user
        Rails.logger.debug("Streaming Publish Job #{publish_job.id} for user #{username}")
        true
      else
        Rails.logger.warning("User #{username} does not have permission to view PublishJob #{publish_job.id}")
        false
      end
    end
end

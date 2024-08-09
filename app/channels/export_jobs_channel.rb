# frozen_string_literal: true

# Channel for Export Jobs
class ExportJobsChannel < ApplicationCable::Channel
  def subscribed
    export_job = ExportJob.find(params[:id])
    Rails.logger.debug("Received subscription for ExportJob #{export_job.id} from user #{username}")
    stream_for export_job if authorized_to_stream export_job
  end

  # Called by the client with an export job id. This method triggers an
  # immediate status update job, where server will send a broadcast message
  # to trigger a status update on the client.
  #
  # This method is intended to work around an issue where the client has
  # missed a status update for an export job (such as validation) and there
  # are no further updates, which otherwise would leave the client thinking
  # the job was still in an "in progress" state.
  def export_job_status_check(data)
    job_id = data['jobId']
    export_job = ExportJob.find(job_id)
    return if export_job.nil?

    ExportJobStatusUpdatedJob.perform_now(export_job)
  end

  private

    def username
      current_user.cas_directory_id
    end

    # confirm that the current user should be able to subscribe to this export job
    def authorized_to_stream(export_job)
      if current_user.admin? || export_job.cas_user == current_user
        Rails.logger.debug("Streaming Export Job #{export_job.id} for user #{username}")
        true
      else
        Rails.logger.warning("User #{username} does not have permission to view ExportJob #{export_job.id}")
        false
      end
    end
end

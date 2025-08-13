# frozen_string_literal: true

# Channel for Import Jobs
class ImportJobsChannel < ApplicationCable::Channel
  def subscribed
    import_job = ImportJob.find(params[:id])
    username = current_user.cas_directory_id
    Rails.logger.debug { "Received subscription for ImportJob #{import_job.id} from user #{username}" }
    stream_for import_job if authorized_to_stream import_job
  end

  # Called by the client with an import job id. This method triggers an
  # immediate status update job, where server will send a broadcast message
  # to trigger a status update on the client.
  #
  # This method is intended to work around an issue where the client has
  # missed a status update for an import job (such as validation) and there
  # are no further updates, which otherwise would leave the client thinking
  # the job was still in an "in progress" state.
  def import_job_status_check(data)
    job_id = data['jobId']
    import_job = ImportJob.find(job_id)
    return if import_job.nil?

    Rails.logger.debug { "Performing ImportJobStatusUpdatedJob ImportJob #{job_id}" }
    ImportJobStatusUpdatedJob.perform_now(import_job)
  end

  private

    def username
      current_user.cas_directory_id
    end

    # confirm that the current user should be able to subscribe to this import job
    def authorized_to_stream(import_job)
      if current_user.admin? || import_job.cas_user == current_user
        Rails.logger.debug { "Streaming Import Job #{import_job.id} for user #{username}" }
        true
      else
        Rails.logger.warning("User #{username} does not have permission to view ImportJob #{import_job.id}")
        false
      end
    end
end

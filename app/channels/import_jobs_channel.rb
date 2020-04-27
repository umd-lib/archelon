# frozen_string_literal: true

# Channel for Import Jobs
class ImportJobsChannel < ApplicationCable::Channel
  def follow
    stop_all_streams
    if current_user.admin?
      stream_from ImportJobsChannel.admins_stream
    else
      stream_from ImportJobsChannel.stream(current_user)
    end
  end

  def unfollow
    stop_all_streams
  end

  # Called by the client with containing a list of import jobs with their
  # statuses as known to the client. This method checks the given statuses
  # against the the actual status on the server. If there is a mismatch, the
  # server will send a broadcast message to trigger an update on
  # the client. If there is no mismatch, no action is taken.
  #
  # This method is intended to work around an issue where the client has
  # missed a status update for an import job (such as validation) and there
  # are no further updates, which otherwise would leave the client thinking
  # the job was still in an "in progress" state.
  def import_job_status_check(data) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    jobs = data['jobs']
    return if jobs.nil?

    jobs.each do |job|
      job_id = job['jobId']
      stage = job['stage']
      status = job['status']
      import_job = ImportJob.find_by(id: job_id)
      next if import_job.nil?

      needs_update = (import_job.stage != stage) || (import_job.status.to_s != status)

      # Sends an update on the first match that needs an update,
      # as we assume that client will just do a page update.
      ImportJobsChannel.broadcast(import_job) && break if needs_update
    end
  end

  # Broadcasts import job information to the appropriate stream(s)
  def self.broadcast(import_job)
    user = import_job.cas_user

    unless user.admin?
      # Don't broadcast on per-user stream if user is an admin, as they
      # will get the message on the "admins" stream
      user_stream = ImportJobsChannel.stream(user)
      ActionCable.server.broadcast user_stream, import_job: import_job
    end

    admins_stream = ImportJobsChannel.admins_stream
    ActionCable.server.broadcast admins_stream, import_job: import_job
  end

  # Stream that sends status message to the user that created the import job
  def self.stream(user)
    "import_jobs:#{user.id}:status"
  end

  # Stream for sending status messages to admins, regardless of who created
  # the import job.
  def self.admins_stream
    'import_jobs:admins:status'
  end
end

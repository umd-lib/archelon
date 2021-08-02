# frozen_string_literal: true

# Channel for Import Jobs
#
# This class uses follow/unfollow methods, instead of simply using
# subscribe/unsubscribe methods, because currently ImportJobChannels are
# created for all pages, but we only want particular pages to
# by updated when import job updates occur.
#
# Using follow/unfollow allows enables a page to subscribe for updates
# based on app/assets/javascripts/channels/import_jobs.coffee settings.
class ImportJobsChannel < ApplicationCable::Channel
  # Used for following updates for any import job.
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
  def import_job_status_check(data) # rubocop:disable Metrics/MethodLength
    jobs = data['jobs']
    return if jobs.nil?

    updated_jobs = []
    jobs.each do |job|
      job_id = job['jobId']
      state = job['state']
      import_job = ImportJob.find_by(id: job_id)
      next if import_job.nil?

      needs_update = import_job.state != state
      updated_jobs << import_job if needs_update
    end

    # Sends an update
    ImportJobsChannel.broadcast(updated_jobs) unless updated_jobs.empty?
  end

  # Broadcasts import job information to the appropriate stream(s)
  def self.broadcast(import_jobs)
    # Split the import jobs into groups by user.
    # This prevents users from seeing information about jobs they don't
    # own.
    import_jobs_by_user = import_jobs.group_by(&:cas_user)
    users = import_jobs_by_user.keys

    users.each do |user|
      # Don't broadcast on per-user stream if user is an admin, as they
      # will get the message on the "admins" stream
      next if user.admin?

      user_stream = ImportJobsChannel.stream(user)
      ActionCable.server.broadcast user_stream, import_jobs: import_jobs_by_user[user]
    end

    # Admins can see all the jobs
    admins_stream = ImportJobsChannel.admins_stream
    ActionCable.server.broadcast admins_stream, import_jobs: import_jobs
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

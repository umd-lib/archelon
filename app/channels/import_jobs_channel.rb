# frozen_string_literal: true

# Channel for Import Jobs
class ImportJobsChannel < ApplicationCable::Channel
  def follow
    stop_all_streams
    if current_user.admin?
      stream_from ImportJobsChannel.admins_channel_name
    else
      stream_from ImportJobsChannel.channel_name(current_user)
    end
  end

  def unfollow
    stop_all_streams
  end

  # Broadcasts import job information to the appropriate channel(s)
  def self.broadcast(import_job)
    user = import_job.cas_user

    unless user.admin?
      # Don't broadcast on per-user channel if user is an admin, as they
      # will get the message on the "admins" channel
      channel_name = ImportJobsChannel.channel_name(user)
      ActionCable.server.broadcast channel_name, import_job: import_job
    end

    admins_channel_name = ImportJobsChannel.admins_channel_name
    ActionCable.server.broadcast admins_channel_name, import_job: import_job
  end

  # Channel that sends status message to the user that created the import job
  def self.channel_name(user)
    "import_jobs:#{user.id}:status"
  end

  # Channel for sending status messages to admins, regardless of who created
  # the import job.
  def self.admins_channel_name
    'import_jobs:admins:status'
  end
end

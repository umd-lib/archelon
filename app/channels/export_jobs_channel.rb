# frozen_string_literal: true

# Channel for Export Jobs
class ExportJobsChannel < ApplicationCable::Channel
  def follow
    stop_all_streams
    if current_user.admin?
      stream_from ExportJobsChannel.admins_channel_name
    else
      stream_from ExportJobsChannel.channel_name(current_user)
    end
  end

  def unfollow
    stop_all_streams
  end

  # Broadcasts export job information to the appropriate channel(s)
  def self.broadcast(export_job)
    message = ExportJobsChannel.render_message(export_job)
    user = export_job.cas_user

    unless user.admin?
      # Don't broadcast on per-user channel if user is an admin, as they
      # will get the message on the "admins" channel
      channel_name = ExportJobsChannel.channel_name(user)
      ActionCable.server.broadcast channel_name, export_job: export_job, message: message
    end

    admins_channel_name = ExportJobsChannel.admins_channel_name
    ActionCable.server.broadcast admins_channel_name, export_job: export_job, message: message
  end

  # Channel that sends status message to the user that created the export job
  def self.channel_name(user)
    "export_jobs:#{user.id}:status"
  end

  # Channel for sending status messages to admins, regardless of who created
  # the export job.
  def self.admins_channel_name
    'export_jobs:admins:status'
  end

  # Renders the message to send
  def self.render_message(export_job)
    ApplicationController.renderer.render(partial: 'export_jobs/export_job_status', locals: { export_job: export_job })
  end
end

# frozen_string_literal: true

# Channel for Export Jobs
class ExportJobsChannel < ApplicationCable::Channel
  def follow
    stop_all_streams
    if current_user.admin?
      stream_from ExportJobsChannel.admins_stream
    else
      stream_from ExportJobsChannel.stream(current_user)
    end
  end

  def unfollow
    stop_all_streams
  end

  # Broadcasts export job information to the appropriate channel(s)
  def self.broadcast(export_job)
    user = export_job.cas_user

    message = { job: export_job, htmlUpdate: html_update(export_job) }

    unless user.admin?
      # Don't broadcast on per-user stream if user is an admin, as they
      # will get the message on the "admins" stream
      user_stream = ExportJobsChannel.stream(user)
      ActionCable.server.broadcast user_stream, export_job: message
    end

    admins_stream = ExportJobsChannel.admins_stream
    ActionCable.server.broadcast admins_stream, export_job: message
  end

  # Stream that sends status message to the user that created the export job
  def self.stream(user)
    "export_jobs:#{user.id}:status"
  end

  # Stream for sending status messages to admins, regardless of who created
  # the export job.
  def self.admins_stream
    'export_jobs:admins:status'
  end

  # Returns the updated HTML to render
  def self.html_update(export_job)
    ActionController::Renderer.for(ExportJobsController).render partial: 'export_job_table_row',
                                                                locals: { export_job: export_job }
  end
end

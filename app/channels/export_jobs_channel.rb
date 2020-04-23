# frozen_string_literal: true

# Channel for Export Jobs
class ExportJobsChannel < ApplicationCable::Channel
  def follow
    stop_all_streams
    stream_from ExportJobsChannel.channel_name(current_user)
  end

  def unfollow
    stop_all_streams
  end

  def self.channel_name(user)
    "export_jobs:#{user.id}:status"
  end
end

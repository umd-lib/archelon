# frozen_string_literal: true

# Channel for Export Jobs
class ExportJobsChannel < ApplicationCable::Channel
  def follow
    stop_all_streams
    stream_from 'export_jobs:status'
  end

  def unfollow
    stop_all_streams
  end
end

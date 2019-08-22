# frozen_string_literal: true

class ExportJobsController < ApplicationController
  def index
    @jobs = ExportJob.where(cas_user: current_cas_user).order('timestamp DESC')
  end

  def new
    default_name = "#{current_cas_user.cas_directory_id}-#{Time.now.iso8601}"
    @job = ExportJob.new(name: default_name)
  end

  def create # rubocop:disable Metrics/MethodLength, Metrics/AbcSize,
    uris = uris_to_export
    return unless uris

    @job = create_job(params.require(:export_job).permit(:name, :format))
    return unless @job.save

    begin
      STOMP_CLIENT.publish Rails.configuration.queues[:export_jobs], uris.join("\n"), headers(@job)
    rescue Stomp::Error::NoCurrentConnection
      @job.status = 'Error'
      @job.save
      flash[:error] = I18n.t(:active_mq_is_down)
    end

    redirect_to action: 'index', status: :see_other
  end

  private

    def create_job(args)
      args[:timestamp] = Time.zone.now
      args[:cas_user] = current_cas_user
      args[:status] = ExportJob::IN_PROGRESS
      ExportJob.new(args)
    end

    def uris_to_export
      params[:uris].to_s.split("\n").map(&:strip).reject(&:empty?)
    end

    def headers(job)
      {
        ArchelonExportJobName: job.name,
        ArchelonExportJobId: job.id,
        ArchelonExportJobUsername: job.cas_user.cas_directory_id,
        ArchelonExportJobFormat: job.format,
        ArchelonExportJobTimestamp: job.timestamp,
        persistent: 'true'
      }
    end
end

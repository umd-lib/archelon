# frozen_string_literal: true

class ExportJobsController < ApplicationController
  before_action :cancel_workflow?, only: %i[create review]
  before_action :selected_items?, only: %i[new create review]
  before_action :selected_items_changed?, only: :create

  def index
    @jobs =
      if current_cas_user.admin?
        ExportJob.all.order('timestamp DESC')
      else
        ExportJob.where(cas_user: current_cas_user).order('timestamp DESC')
      end
  end

  def new
    name = params[:name] || "#{current_cas_user.cas_directory_id}-#{Time.now.iso8601}"
    format = params[:_format] || ExportJob::CSV_FORMAT
    @job = ExportJob.new(name: name, format: format)
  end

  def review
    @job = ExportJob.new(params.require(:export_job).permit(:name, :format))
    @job.item_count = current_user.bookmarks.count
  end

  def create # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    uris = current_user.bookmarks.map(&:document_id)
    @job = create_job(params.require(:export_job).permit(:name, :format, :item_count))
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

    def cancel_workflow?
      redirect_to controller: :bookmarks, action: :index if params[:commit] == 'Cancel'
    end

    def selected_items?
      return unless current_user.bookmarks.count.zero?

      flash[:error] = I18n.t(:needs_selected_items)
      redirect_to controller: :bookmarks, action: :index
    end

    def selected_items_changed?
      return if params[:export_job][:item_count] == current_user.bookmarks.count.to_s

      flash[:notice] = I18n.t(:selected_items_changed)
      review
      render :review
    end

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

# frozen_string_literal: true

class ExportJobsController < ApplicationController # rubocop:disable Metrics/ClassLength
  before_action -> { authorize! :manage, ExportJob }, except: %i[download download_binaries]
  before_action -> { authorize! :download, ExportJob }, only: %i[download download_binaries]
  before_action :set_export_job, only: %i[download download_binaries]
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
    @job = ExportJob.new(params.key?(:export_job) ? export_job_params : default_job_params)
  end

  def review
    @job = ExportJob.new(export_job_params)
    @job.item_count = bookmarks.count
    return unless @job.export_binaries

    binary_stats = BinariesStats.get_stats(bookmarks.map(&:document_id))
    @job.binaries_size = binary_stats[:total_size]
    @job.binaries_count = binary_stats[:count]
  end

  def create
    @job = create_job(export_job_params)
    return unless @job.save

    begin
      submit_job(bookmarks.map(&:document_id))
    rescue Stomp::Error::NoCurrentConnection
      @job.plastron_status = :plastron_status_error
      @job.save
      flash[:error] = I18n.t(:active_mq_is_down)
    end
    redirect_to action: 'index', status: :see_other
  end

  def download
    send_data(*@job.download_file)
  end

  def download_binaries
    send_file(@job.binaries_file)
  rescue ActionController::MissingFile
    render file: Rails.root.join('public', '404.html'), status: :not_found
  end

  private

    def export_job_params
      params
        .require(:export_job)
        .permit(:name, :format, :export_binaries, :item_count, :binaries_size, :binaries_count)
        .with_defaults(default_job_params)
    end

    def default_job_params
      {
        name: "#{current_cas_user.cas_directory_id}-#{Time.now.iso8601}",
        format: ExportJob::CSV_FORMAT,
        export_binaries: false
      }
    end

    def set_export_job
      @job = ExportJob.find(params[:id])
    end

    def bookmarks
      current_user.bookmarks
    end

    def cancel_workflow?
      redirect_to controller: :bookmarks, action: :index if params[:commit] == 'Cancel'
    end

    def selected_items?
      return unless current_user.bookmarks.count.zero?

      flash[:error] = I18n.t(:needs_selected_items)
      redirect_to controller: :bookmarks, action: :index
    end

    def selected_items_changed?
      return if params[:export_job][:item_count] == bookmarks.count.to_s

      flash[:notice] = I18n.t(:selected_items_changed)
      review
      render :review
    end

    def create_job(args)
      ExportJob.new(args).tap do |job|
        job.timestamp = Time.zone.now
        job.cas_user = current_cas_user
        job.progress = 0
        job.plastron_status = :plastron_status_pending
      end
    end

    def message_headers(job)
      {
        PlastronCommand: 'export',
        PlastronJobId: export_job_url(job),
        'PlastronArg-name': job.name,
        'PlastronArg-on-behalf-of': job.cas_user.cas_directory_id,
        'PlastronArg-format': job.format,
        'PlastronArg-timestamp': job.timestamp,
        'PlastronArg-export-binaries': job.export_binaries.to_s,
        persistent: 'true'
      }
    end

    def submit_job(uris)
      body = uris.join("\n")
      headers = message_headers(@job)
      if StompService.publish_message :jobs, body, headers
        @job.plastron_status = :plastron_status_in_progress
        @job.save!
      else
        @job.plastron_status = :plastron_status_error
        @job.save!
        flash[:error] = I18n.t(:active_mq_is_down)
      end
    end
end

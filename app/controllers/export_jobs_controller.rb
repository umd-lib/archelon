# frozen_string_literal: true

class ExportJobsController < ApplicationController # rubocop:disable Metrics/ClassLength
  before_action -> { authorize! :manage, ExportJob }, except: %i[download download_binaries status_update]
  before_action -> { authorize! :download, ExportJob }, only: %i[download download_binaries]
  before_action :set_export_job, only: %i[download download_binaries status_update]
  before_action :cancel_workflow?, only: %i[create review]
  before_action :selected_items?, only: %i[new create review]
  before_action :selected_items_changed?, only: :create
  skip_before_action :authenticate, only: %i[status_update]

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
    export_uris = bookmarks.map(&:document_id)
    @mime_types = MimeTypes.mime_types(export_uris)
  end

  def review # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    @job = ExportJob.new(export_job_params)

    if @job.export_binaries
      binary_stats = BinariesStats.get_stats(bookmarks.map(&:document_id))
      @job.binaries_size = binary_stats[:total_size]
      @job.binaries_count = binary_stats[:count]
      @job.item_count = bookmarks.count

      selected_mime_types = params.dig('export_job', 'mime_types')
      if selected_mime_types.blank?
        flash[:error] = I18n.t(:export_job_no_mime_types_selected)
        redirect_to controller: :export_jobs, action: :new
        return
      end

      binary_stats = BinariesStats.get_stats(bookmarks.map(&:document_id), selected_mime_types)
      @job.binaries_size = binary_stats[:total_size]
      @job.binaries_count = binary_stats[:count]

      mime_types = selected_mime_types.join(',')
      @job.mime_types = mime_types
    end

    if @job.job_submission_allowed?
      render :review
    else
      render :job_submission_not_allowed
    end
  end

  def create # rubocop:disable Metrics/MethodLength
    @job = create_job(export_job_params)
    render :job_submission_not_allowed && return unless @job.job_submission_allowed?

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

  # GET /export_jobs/1/status_update
  def status_update
    # Triggers export job notification to channel
    ExportJobRelayJob.perform_later(@job)
    render :no_content
  end

  private

    def export_job_params
      params
        .require(:export_job)
        .permit(:name, :format, :export_binaries, :item_count, :binaries_size, :binaries_count, :mime_types)
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

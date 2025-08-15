# frozen_string_literal: true

class ExportJobsController < ApplicationController # rubocop:disable Metrics/ClassLength
  before_action -> { authorize! :manage, ExportJob }, except: %i[download status_update]
  before_action -> { authorize! :download, ExportJob }, only: %i[download]
  before_action :set_export_job, only: %i[download status_update]
  before_action :cancel_workflow?, only: %i[create review]
  before_action :selected_items?, only: %i[new create review]
  before_action :selected_items_changed?, only: :create
  skip_before_action :authenticate, only: %i[status_update]
  skip_before_action :verify_authenticity_token, only: :status_update

  def index
    @jobs =
      if current_cas_user.admin?
        ExportJob.order(timestamp: :desc)
      else
        ExportJob.where(cas_user: current_cas_user).order(timestamp: :desc)
      end
  end

  def show
    id = params[:id]
    @job = ExportJob.find(id)
    @cas_user = CasUser.find(@job.cas_user_id)
  end

  def new
    @job = ExportJob.new(params.key?(:export_job) ? export_job_params : default_job_params)
    export_uris = bookmarks.map(&:document_id)
    @mime_types = MimeTypes.mime_types(export_uris)
  end

  def create
    @job = create_job(export_job_params)
    render :job_submission_not_allowed and return unless @job.job_submission_allowed?

    @job.uris = bookmarks.map(&:document_id).join("\n")

    return unless @job.save

    submit_job
    redirect_to action: 'index', status: :see_other
  end

  def destroy
    job = ExportJob.find(params[:id])

    FileUtils.rm_f(job.path)

    ExportJob.destroy(params[:id])
    redirect_to export_jobs_path, status: :see_other
  end

  def review # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    @job = ExportJob.new(export_job_params)
    @job.item_count = bookmarks.count

    selected_mime_types = params.dig('export_job', 'mime_types')
    @job.export_binaries = selected_mime_types.present?

    if @job.export_binaries
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

  def download
    send_file(@job.path)
  rescue ActionController::MissingFile
    not_found
  end

  # POST /export_jobs/1/status_update
  def status_update
    # Triggers export job notification to channel;
    # it is important to use perform_now so that
    # ActionCable receives timely updates
    ExportJobStatusUpdatedJob.perform_now(@job)
    render status: :no_content
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
      return unless current_user.bookmarks.none? # rubocop:disable Style/ReturnNilInPredicateMethodDefinition

      flash[:error] = I18n.t(:needs_selected_items)
      redirect_to controller: :bookmarks, action: :index
    end

    def selected_items_changed?
      return if params[:export_job][:item_count] == bookmarks.count.to_s # rubocop:disable Style/ReturnNilInPredicateMethodDefinition

      flash[:notice] = I18n.t(:selected_items_changed)
      review
    end

    def create_job(args)
      ExportJob.new(args).tap do |job|
        job.timestamp = Time.zone.now
        job.cas_user = current_cas_user
        job.progress = 0
        job.state = :pending
      end
    end

    def submit_job
      request = ExportJobRequest.create(
        export_job: @job,
        job_id: export_job_url(@job)
      )
      destination = STOMP_CONFIG['destinations'][:jobs]
      SendStompMessageJob.perform_later destination, request
    end
end

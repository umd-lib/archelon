# frozen_string_literal: true

class ExportJobsController < ApplicationController
  before_action -> { authorize! :manage, ExportJob }, except: :download
  before_action :cancel_workflow?, only: %i[create review]
  before_action :stomp_client_connected?, only: %i[new create review]
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

  def create
    @job = create_job(params.require(:export_job).permit(:name, :format, :item_count))
    return unless @job.save

    begin
      submit_job(current_user.bookmarks.map(&:document_id))
    rescue Stomp::Error::NoCurrentConnection
      @job.plastron_status = :plastron_status_error
      @job.save
      flash[:error] = I18n.t(:active_mq_is_down)
    end
    redirect_to action: 'index', status: :see_other
  end

  def download
    job = ExportJob.find(params[:id])

    # Authorizing here because we aren't using CanCanCan "load_and_authorize_resource"
    authorize! :download, job

    send_data(*job.download_file)
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

    def stomp_client_connected?
      return if STOMP_CLIENT.connected?

      # try to reconnect
      STOMP_CLIENT.connect max_reconnect_attempts: 3
      return if STOMP_CLIENT.connected?

      flash[:error] = I18n.t(:active_mq_is_down)
      redirect_to controller: 'bookmarks'
    end

    def selected_items_changed?
      return if params[:export_job][:item_count] == current_user.bookmarks.count.to_s

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
        persistent: 'true'
      }
    end

    def submit_job(uris)
      body = uris.join("\n")
      headers = message_headers(@job)
      STOMP_CLIENT.publish STOMP_CONFIG['destinations']['jobs'], body, headers
      @job.plastron_status = :plastron_status_in_progress
      @job.save!
    end
end

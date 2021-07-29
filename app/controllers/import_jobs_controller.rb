# frozen_string_literal: true

class ImportJobsController < ApplicationController # rubocop:disable Metrics/ClassLength
  before_action :set_import_job, only: %i[update show edit import status_update]
  before_action :cancel_workflow?, only: %i[create update]
  helper_method :status_text
  skip_before_action :authenticate, only: %i[status_update]

  # GET /import_jobs
  # GET /import_jobs.json
  def index
    @import_jobs =
      if current_cas_user.admin?
        ImportJob.all.order('timestamp DESC').paginate(page: params[:page])
      else
        ImportJob.where(cas_user: current_cas_user).order('timestamp DESC').paginate(page: params[:page])
      end
  end

  # GET /import_jobs/1
  # GET /import_jobs/1.json
  def show
    @import_job_response = @import_job.last_response
    job_id = import_job_url(@import_job)
    @import_job_info = PlastronService.retrieve_import_job_info(job_id)
  end

  # GET /import_jobs/new
  def new
    name = params[:name] || "#{current_cas_user.cas_directory_id}-#{Time.now.iso8601}"
    @import_job = ImportJob.new(name: name)
    @collections_options_array = retrieve_collections
    @binaries_files = Dir.children(IMPORT_CONFIG[:binaries_dir])&.select { |filename| filename =~ /\.zip$/ }
  end

  # GET /import_jobs/1/edit
  def edit
    if @import_job.stage == 'import'
      flash[:error] = I18n.t(:import_already_performed)
      redirect_to action: 'index', status: :see_other
      return
    end

    @import_job_response = @import_job.last_response
    @collections_options_array = retrieve_collections
    @binaries_files = Dir.children(IMPORT_CONFIG[:binaries_dir])&.select { |filename| filename =~ /\.zip$/ }
  end

  # POST /import_jobs
  # POST /import_jobs.json
  def create
    @import_job = create_job(import_job_params)
    if @import_job.save
      submit_job(@import_job, true)
      redirect_to action: 'index', status: :see_other
      return
    end

    @collections_options_array = retrieve_collections
    render :new
  end

  def update # rubocop:disable Metrics/MethodLength
    if @import_job.stage == 'import'
      flash[:error] = I18n.t(:import_already_performed)
      redirect_to action: 'index', status: :see_other
      return
    end

    if valid_update && @import_job.save
      submit_job(@import_job, true)
      redirect_to action: 'index', status: :see_other
      return
    end

    @import_job_response = @import_job.last_response
    @collections_options_array = retrieve_collections
    render :edit
  end

  def import # rubocop:disable Metrics/MethodLength
    if @import_job.status == :import_success || @import_job.status == :import_failed
      flash[:error] = I18n.t(:import_already_performed)
      redirect_to action: 'index', status: :see_other
      return
    end

    if @import_job.status == :validate_failed
      flash[:error] = I18n.t(:cannot_import_invalid_file)
      redirect_to action: 'index', status: :see_other
      return
    end

    submit_job(@import_job, false)
    @import_job.stage = 'import'
    @import_job.save!
    redirect_to action: 'index', status: :see_other
  end

  # Generates status text display for the GUI
  def status_text(import_job) # rubocop:disable Metrics/MethodLength
    if import_job.status == :in_progress
      status_text = I18n.t('activerecord.attributes.import_job.status.in_progress')
      progress = import_job.progress
      if !progress.nil? && progress.positive?
        stage_text = I18n.t("activerecord.attributes.import_job.stage.#{import_job.stage}")
        status_text = "#{stage_text} (#{progress}%)"
      end
      status_text
    else
      I18n.t("activerecord.attributes.import_job.status.#{import_job.status}")
    end
  end

  # GET /import_jobs/1/status_update
  def status_update
    # Triggers import job notification to channel
    ImportJobRelayJob.perform_later(@import_job)
    render plain: '', status: :no_content
  end

  private

    def cancel_workflow?
      redirect_to controller: :import_jobs, action: :index if params[:commit] == 'Cancel'
    end

    def set_import_job
      @import_job = ImportJob.find(params[:id])
    end

    # Returns an array of arrays, the first element being the collection title,
    # the second element the URI of the collection.
    #
    # If an error occurs, an empty array is returned.
    def retrieve_collections
      collections = RepositoryCollections.list
      collections.map { |c| [c[:display_title], c[:uri]] }
    rescue StandardError
      flash[:error] = I18n.t(:solr_is_down)
      []
    end

    def create_job(args)
      ImportJob.new(args).tap do |job|
        job.timestamp = Time.zone.now
        job.cas_user = current_cas_user
        job.stage = 'validate'
        job.plastron_status = :plastron_status_pending
      end
    end

    def submit_job(import_job, validate_only)
      job_id = import_job_url(import_job)
      import_job_request = ImportJobRequest.new(job_id, import_job, validate_only)

      import_job.plastron_status = :plastron_status_in_progress
      import_job.save!
      StompService.publish_message(:jobs, import_job_request.body, import_job_request.headers) && return

      # if we were unable to send the message
      import_job.plastron_status = :plastron_status_error
      import_job.save!
      flash[:error] = I18n.t(:active_mq_is_down)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def import_job_params
      safe_params = params.require(:import_job).permit(:name, :model, :access, :collection,
                                                       :metadata_file, :binaries_zip_filename)
      location = binaries_location(safe_params.delete(:binaries_zip_filename))
      # if this import job has binaries construct the location to pass to plastron
      safe_params[:binaries_location] = location if location.present?
      safe_params
    end

    def binaries_location(filename)
      filename.present? ? File.join(IMPORT_CONFIG[:binaries_base_location], filename) : nil
    end

    def valid_update
      @import_job.update(import_job_params)

      # Need special handing of "metadata_file", because if we're gotten this
      # far, the @import_job already has a file attached, so the
      # "attachment_validation" method on the model won't catch that the
      # update form submission doesn't have new file attached.
      #
      # Need to have the method after the call to @import_job.update, as
      # update clears the "errors" array
      if import_job_params['metadata_file'].nil?
        @import_job.errors.add(:metadata_file, :required)
        return false
      end

      true
    end
end

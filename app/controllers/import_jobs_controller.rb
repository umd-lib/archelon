# frozen_string_literal: true

class ImportJobsController < ApplicationController # rubocop:disable Metrics/ClassLength
  before_action :set_import_job, only: %i[update show edit start_validation start_import resume_import
                                          import status_update]
  before_action :cancel_workflow?, only: %i[create update]
  helper_method :status_text
  skip_before_action :authenticate, only: %i[status_update]
  skip_before_action :verify_authenticity_token, only: :status_update

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
    job_id = import_job_url(@import_job)
    @import_job_info = PlastronService.retrieve_import_job_info(job_id)

    # Generate catalog URI for each completed item
    @import_job_info.completed.each do |item|
      uri = item['uri']
      catalog_uri = solr_document_url(uri)
      item['catalog_uri'] = catalog_uri
    end
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
    if @import_job.import_complete?
      flash[:error] = I18n.t(:import_already_performed)
      return redirect_to action: 'index', status: :see_other
    end

    @collections_options_array = retrieve_collections
    @binaries_files = Dir.children(IMPORT_CONFIG[:binaries_dir])&.select { |filename| filename =~ /\.zip$/ }
  end

  # POST /import_jobs
  # POST /import_jobs.json
  def create
    @import_job = create_job(import_job_params)
    if @import_job.save
      start_validation
      return redirect_to action: 'index', status: :see_other
    end

    @collections_options_array = retrieve_collections
    render :new
  end

  def update
    if @import_job.import_complete?
      flash[:error] = I18n.t(:import_already_performed)
      return redirect_to action: 'index', status: :see_other
    end

    if valid_update && @import_job.save
      start_validation
      return redirect_to action: 'index', status: :see_other
    end

    @collections_options_array = retrieve_collections
    render :edit
  end

  def import # rubocop:disable Metrics/MethodLength
    if @import_job.import_complete?
      flash[:error] = I18n.t(:import_already_performed)
    elsif @import_job.validate_failed?
      flash[:error] = I18n.t(:cannot_import_invalid_file)
    elsif @import_job.validate_success?
      start_import
    elsif @import_job.import_incomplete?
      resume_import
    else
      flash[:error] = 'Cannot start or resume this import'
    end
    redirect_to action: 'index', status: :see_other
  end

  # Generates status text display for the GUI
  def status_text(import_job)
    return '' if import_job.state.blank?

    return I18n.t("activerecord.attributes.import_job.status.#{import_job.state}") unless import_job.import_in_progress?

    I18n.t('activerecord.attributes.import_job.status.import_in_progress') + import_job.progress_text
  end

  # POST /import_jobs/1/status_update
  def status_update
    # Triggers import job notification to channel;
    # it is important to use perform_now so that
    # ActionCable receives timely updates
    ImportJobStatusUpdatedJob.perform_now(@import_job)
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
        job.state = :validate_pending
      end
    end

    def job_request(job, validate_only: false, resume: false)
      ImportJobRequest.create(
        import_job: job,
        job_id: import_job_url(job),
        validate_only: validate_only,
        resume: resume
      )
    end

    def jobs_destination
      STOMP_CONFIG['destinations'][:jobs]
    end

    def start_validation
      SendStompMessageJob.perform_later jobs_destination, job_request(@import_job, validate_only: true)
      @import_job.validate_pending!
    end

    def start_import
      # must set resume to 'true' since there will already be a job directory that was created
      # by the validation phase, and Plastron complains if you try to start a job when there is
      # an existing directory for it
      SendStompMessageJob.perform_later jobs_destination, job_request(@import_job, resume: true)
      @import_job.import_pending!
    end

    def resume_import
      SendStompMessageJob.perform_later jobs_destination, job_request(@import_job, resume: true)
      @import_job.import_pending!
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

      if import_job_params['metadata_file'].present?
        # delete existing attachment and attach new metadata file
        @import_job.metadata_file.purge
        @import_job.metadata_file.attach(import_job_params[:metadata_file])
      end

      true
    end
end

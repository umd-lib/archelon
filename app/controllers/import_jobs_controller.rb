# frozen_string_literal: true

class ImportJobsController < ApplicationController # rubocop:disable Metrics/ClassLength
  before_action :set_import_job, only: %i[update show edit import]
  before_action :cancel_workflow?, only: %i[create update]
  helper_method :status_text

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
  end

  # GET /import_jobs/new
  def new
    name = params[:name] || "#{current_cas_user.cas_directory_id}-#{Time.now.iso8601}"
    @import_job = ImportJob.new(name: name)
    @collections_options_array = retrieve_collections
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

  def update # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    if @import_job.stage == 'import'
      flash[:error] = I18n.t(:import_already_performed)
      redirect_to action: 'index', status: :see_other
      return
    end

    valid_update = @import_job.update(import_job_params)

    # Need special handing of "file_to_upload", because if we're gotten this
    # far, the @import_job already has a file attached, so the
    # "attachment_validation" method on the model won't catch that the
    # update form submission doesn't have new file attached.
    #
    # Need to have the method after the call to @import_job.update, as
    # update clears the "errors" array
    if import_job_params['file_to_upload'].nil?
      @import_job.errors.add(:file_to_upload, :required)
      valid_update = false
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
      body = import_job.file_to_upload.download
      headers = message_headers(import_job, validate_only)

      import_job.plastron_status = :plastron_status_in_progress
      import_job.save!
      STOMP_CLIENT.publish STOMP_CONFIG['destinations']['jobs'], body, headers
    rescue Stomp::Error::NoCurrentConnection
      import_job.plastron_status = :plastron_status_error
      import_job.save!
      flash[:error] = I18n.t(:active_mq_is_down)
    end

    def message_headers(job, validate_only) # rubocop:disable Metrics/MethodLength
      {
        PlastronCommand: 'import',
        PlastronJobId: import_job_url(job),
        'PlastronArg-model': job.model,
        'PlastronArg-name': job.name,
        'PlastronArg-on-behalf-of': job.cas_user.cas_directory_id,
        'PlastronArg-member-of': job.collection,
        'PlastronArg-timestamp': job.timestamp
      }.tap do |headers|
        headers['PlastronArg-access'] = "<#{job.access}>" if job.access.present?
        headers['PlastronArg-validate-only'] = 'True' if validate_only
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def import_job_params
      params.require(:import_job).permit(:name, :model, :access, :collection, :file_to_upload, :binary_zip_file)
    end
end

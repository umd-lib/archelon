class ImportJobsController < ApplicationController
  before_action :set_import_job, only: %i[show edit update destroy]
  before_action :cancel_workflow?, only: %i[create]

  # GET /import_jobs
  # GET /import_jobs.json
  def index
    @import_jobs =
      if current_cas_user.admin?
        ImportJob.all.order('timestamp DESC')
      else
        ImportJob.where(cas_user: current_cas_user).order('timestamp DESC')
      end
  end

  # GET /import_jobs/1
  # GET /import_jobs/1.json
  def show
    response_message = @import_job.plastron_operation.response_message
    import_job_response = ImportJobResponse.new(response_message)

    @valid = import_job_response.valid?
    @num_total = import_job_response.num_total
    @num_valid = import_job_response.num_valid
    @num_invalid = import_job_response.num_invalid
    @num_error = import_job_response.num_error

    invalid_lines = import_job_response.invalid_lines

    @invalid_line_descriptions = []
    invalid_lines.each do |line|
      if line.line_error?
        @invalid_line_descriptions << line.line_error
      elsif line.field_errors?
        bad_fields = line.field_errors.join(',')
        description = "#{line.line_location}, #{bad_fields}"
        @invalid_line_descriptions << description
      end
    end
  end

  # GET /import_jobs/new
  def new
    name = params[:name] || "#{current_cas_user.cas_directory_id}-#{Time.now.iso8601}"
    @import_job = ImportJob.new(name: name)
  end

  # GET /import_jobs/1/edit
  def edit
  end

  # POST /import_jobs
  # POST /import_jobs.json
  def create
    @import_job = create_job(import_job_params)
    return unless @import_job.save

    begin
      submit_job(@import_job)
    rescue Stomp::Error::NoCurrentConnection
      @job.plastron_operation.status = :error
      @job.status = 'Error'
      @job.save
      @job.plastron_operation.save!
      flash[:error] = I18n.t(:active_mq_is_down)
    end
    redirect_to action: 'index', status: :see_other
  end

  # PATCH/PUT /import_jobs/1
  # PATCH/PUT /import_jobs/1.json
  def update
    respond_to do |format|
      if @import_job.update(import_job_params)
        format.html { redirect_to @import_job, notice: 'Import job was successfully updated.' }
        format.json { render :show, status: :ok, location: @import_job }
      else
        format.html { render :edit }
        format.json { render json: @import_job.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /import_jobs/1
  # DELETE /import_jobs/1.json
  def destroy
    @import_job.destroy
    respond_to do |format|
      format.html { redirect_to import_jobs_url, notice: 'Import job was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def cancel_workflow?
      redirect_to controller: :import_jobs, action: :index if params[:commit] == 'Cancel'
    end

    def set_import_job
      @import_job = ImportJob.find(params[:id])
    end

    def create_job(args)
      ImportJob.new(args).tap do |job|
        job.timestamp = Time.zone.now
        job.cas_user = current_cas_user
        job.plastron_operation = PlastronOperation.new status: :pending, progress: 0
      end
    end

    def submit_job(import_job)
      body = import_job.file_to_upload.download
      headers = message_headers(import_job)

      import_job.plastron_operation.started = Time.zone.now
      import_job.plastron_operation.status = :in_progress
      import_job.plastron_operation.request_message = "#{headers_to_s(headers)}\n\n#{body}"
      import_job.plastron_operation.save!

      STOMP_CLIENT.publish STOMP_CONFIG['destinations']['jobs'], body, headers
    end

    def message_headers(job)
      {
        'PlastronCommand': 'import',
        'PlastronArg-model': 'Issue',
        'PlastronArg-validate-only': 'True',
        'PlastronJobId': import_job_url(job),
        'PlastronArg-name': job.name,
        'PlastronArg-username': job.cas_user.cas_directory_id,
        'PlastronArg-timestamp': job.timestamp
      }
    end

    def headers_to_s(headers)
      headers.map { |k, v| [k, v].join(': ') }.join("\n")
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def import_job_params
      params.require(:import_job).permit(:name, :file_to_upload)
    end
end

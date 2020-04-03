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

    respond_to do |format|
      if @import_job.save
        format.html { redirect_to @import_job, notice: 'Import job was successfully created.' }
        format.json { render :show, status: :created, location: @import_job }
      else
        format.html { render :new }
        format.json { render json: @import_job.errors, status: :unprocessable_entity }
      end
    end
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

    # Use callbacks to share common setup or constraints between actions.
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def import_job_params
      params.require(:import_job).permit(:name, :file_to_upload)
    end
end

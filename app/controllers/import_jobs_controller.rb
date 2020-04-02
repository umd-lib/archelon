class ImportJobsController < ApplicationController
  before_action :set_import_job, only: [:show, :edit, :update, :destroy]

  # GET /import_jobs
  # GET /import_jobs.json
  def index
    @import_jobs = ImportJob.all
  end

  # GET /import_jobs/1
  # GET /import_jobs/1.json
  def show
  end

  # GET /import_jobs/new
  def new
    @import_job = ImportJob.new
  end

  # GET /import_jobs/1/edit
  def edit
  end

  # POST /import_jobs
  # POST /import_jobs.json
  def create
    @import_job = ImportJob.new(import_job_params)

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
    # Use callbacks to share common setup or constraints between actions.
    def set_import_job
      @import_job = ImportJob.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def import_job_params
      params.require(:import_job).permit(:cas_user_id, :plastron_operation_id)
    end
end

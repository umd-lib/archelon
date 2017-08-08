class DownloadUrlsController < ApplicationController
  before_action :set_download_url, only: [:show, :edit, :update, :destroy]

  # GET /download_urls
  # GET /download_urls.json
  def index
    @download_urls = DownloadUrl.all
  end

  # GET /download_urls/1
  # GET /download_urls/1.json
  def show
  end

  # GET /download_urls/new
  def new
    @download_url = DownloadUrl.new
  end

  # GET /download_urls/1/edit
  def edit
  end

  # POST /download_urls
  # POST /download_urls.json
  def create
    @download_url = DownloadUrl.new(download_url_params)

    respond_to do |format|
      if @download_url.save
        format.html { redirect_to @download_url, notice: 'Download url was successfully created.' }
        format.json { render :show, status: :created, location: @download_url }
      else
        format.html { render :new }
        format.json { render json: @download_url.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /download_urls/1
  # PATCH/PUT /download_urls/1.json
  def update
    respond_to do |format|
      if @download_url.update(download_url_params)
        format.html { redirect_to @download_url, notice: 'Download url was successfully updated.' }
        format.json { render :show, status: :ok, location: @download_url }
      else
        format.html { render :edit }
        format.json { render json: @download_url.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /download_urls/1
  # DELETE /download_urls/1.json
  def destroy
    @download_url.destroy
    respond_to do |format|
      format.html { redirect_to download_urls_url, notice: 'Download url was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_download_url
      @download_url = DownloadUrl.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def download_url_params
      params.require(:download_url).permit(:token, :url, :title, :notes, :mimetype, :creator, :enabled, :request_ip, :request_user_agent, :accessed_at, :download_completed_at)
    end
end

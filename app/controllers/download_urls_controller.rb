class DownloadUrlsController < ApplicationController
  before_action :set_download_url, only: [:show]
  include Blacklight::SearchHelper

  # GET /download_urls
  # GET /download_urls.json
  def index
    @q = DownloadUrl.ransack(params[:q])
    @q.sorts = 'created_at desc' if @q.sorts.empty?
    @download_urls = @q.result.paginate(page: params[:page])
  end

  # GET /download_urls/1
  # GET /download_urls/1.json
  def show
  end

  # GET /download_urls/new
  def new
    @download_url = DownloadUrl.new
  end

  # POST /download_urls
  # POST /download_urls.json
  def create # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    @download_url = DownloadUrl.new(download_url_params)
    @download_url.creator = current_cas_user.cas_directory_id

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

  # GET /download_urls/generate/:document_url
  def generate_download_url
    solr_document = find_solr_document(params['document_url'])
    not_found unless solr_document
    @download_url = DownloadUrl.new
    @download_url.url = solr_document[:id]
    @download_url.title = create_default_title(solr_document)
  end

  # POST /download_urls/create/:document_url
  def create_download_url # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    solr_document = find_solr_document(params['document_url'])
    not_found unless solr_document

    @download_url = DownloadUrl.new(download_url_params)
    @download_url.url = solr_document[:id]
    @download_url.mime_type = solr_document[:mime_type]
    @download_url.creator = current_cas_user.cas_directory_id
    @download_url.enabled = true
    @download_url.expires_at = 7.days.from_now

    respond_to do |format|
      if @download_url.save
        format.html do
          redirect_to show_download_url_path(token: @download_url.token),
                      notice: 'Download url was successfully created.'
        end
      else
        format.html { render :generate_download_url }
      end
    end
  end

  # GET /download_urls/show/:token
  def show_download_url
    token = params[:token]
    @download_url = DownloadUrl.find_by(token: token)
  end

  # PUT /download_urls/disable/:token
  def disable # rubocop:disable Metrics/MethodLength
    token = params[:token]
    notice_msg = nil
    @download_url = DownloadUrl.find_by(token: token)
    if @download_url && @download_url.enabled?
      @download_url.enabled = false
      @download_url.save!
      notice_msg = 'Download Url was disabled'
    end

    # Replace with redirect_back_to in Rails 5
    if request.env['HTTP_REFERER'].present?
      redirect_to :back, notice: notice_msg
    else
      redirect_to download_urls_url, notice: notice_msg
    end
  end

  private

    def create_default_title(solr_document)
      title = solr_document[:display_title]
      pcdm_file_of = solr_document[:pcdm_file_of]
      if pcdm_file_of
        file_of_result = fetch(pcdm_file_of)
        file_of_document = file_of_result[1]
        file_of_title = file_of_document[:display_title]
        title += " - #{file_of_title}"
      end
      title
    end

    # Retrieves the Solr document with the given URL, or nil if the Solr
    # document can't be found.
    #
    # The Fedora document URL of the Solr document to retrieve.
    def find_solr_document(document_url)
      results = fetch([document_url])
      solr_documents = results[1]
      return solr_documents.first if solr_documents.any?
      nil
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_download_url
      @download_url = DownloadUrl.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def download_url_params
      # "token", and "creator" should not be settable by the user
      params.require(:download_url).permit(
        :url, :title, :notes, :mime_type, :enabled, :request_ip,
        :request_user_agent, :accessed_at, :download_completed_at
      )
    end
end

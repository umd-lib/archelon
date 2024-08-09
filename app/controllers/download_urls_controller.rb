# frozen_string_literal: true

class DownloadUrlsController < ApplicationController
  load_and_authorize_resource
  # UMD Blacklight 8 Fix
  include Blacklight::Searchable
  # End UMD Blacklight 8 Fix

  # GET /download_urls
  # GET /download_urls.json
  def index
    @rq = DownloadUrl.ransack(query_params)
    @rq.sorts = 'created_at desc' if @rq.sorts.empty?
    @download_urls = @rq.result.paginate(page: params[:page])
    @creators = DownloadUrl.select('creator').distinct.order(:creator)
  end

  # GET /download_urls/1
  # GET /download_urls/1.json
  def show
  end

  # GET /download_urls/generate/:document_url
  def generate_download_url
    solr_document = find_solr_document(params['document_url'])
    not_found && return unless solr_document
    @download_url = DownloadUrl.new
    @download_url.url = solr_document[:id]
    @download_url.title = create_default_title(solr_document)
  end

  # POST /download_urls/create/:document_url
  def create_download_url # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    solr_document = find_solr_document(params['document_url'])
    not_found && return unless solr_document

    @download_url = DownloadUrl.new(download_url_params)
    @download_url.url = solr_document[:id]
    @download_url.mime_type = solr_document[:mime_type]
    @download_url.creator = real_user.cas_directory_id
    @download_url.enabled = true
    @download_url.expires_at = 7.days.from_now
    # Title is not a form parameter, so we have to re-create it in order
    # for it to saved to the model
    @download_url.title = create_default_title(solr_document)

    respond_to do |format|
      if @download_url.save
        format.html do
          redirect_to show_download_url_path(token: @download_url.token),
                      notice: 'Download URL was successfully created.'
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
  def disable
    token = params[:token]
    notice_msg = nil
    @download_url = DownloadUrl.find_by(token: token)
    if @download_url&.enabled?
      @download_url.enabled = false
      @download_url.save!
      notice_msg = 'Download URL was disabled'
    end

    redirect_back fallback_location: download_urls_url, notice: notice_msg
  end

  private

    # Returns the default value for the "title" field of the DownloadUrl object.
    def create_default_title(solr_document)
      title = solr_document[:display_title]
      pcdm_file_of = solr_document[:pcdm_file_of]
      if pcdm_file_of
        # UMD Blacklight 8 Fix
        file_of_document = search_service.fetch(pcdm_file_of)
        # End UMD Blacklight 8 Fix
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
      # UMD Blacklight 8 Fix
      solr_documents = search_service.fetch([document_url])
      # End UMD Blacklight 8 Fix
      return solr_documents.first if solr_documents.any?

      nil
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def download_url_params
      # "token", and "creator" should not be settable by the user
      params.require(:download_url).permit(
        :url, :title, :notes, :mime_type, :enabled, :request_ip,
        :request_user_agent, :accessed_at, :download_completed_at
      )
    end

    # Removes "enabled_eq" if it is 0.
    def query_params
      return if params.blank?

      rq_params = params[:rq]
      rq_params&.delete_if { |key, value| key == 'enabled_eq' && value == '0' }
    end
end

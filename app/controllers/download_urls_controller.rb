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
    @download_urls = @rq.result
    @creators = DownloadUrl.select('creator').distinct.order(:creator)
  end

  # GET /download_urls/1
  # GET /download_urls/1.json
  def show
  end

  def new
    solr_document = find_solr_document(params['document_url'])
    not_found && return unless solr_document

    @download_url = DownloadUrl.new
    @download_url.url = solr_document[:id]
    @download_url.title = create_default_title(solr_document)
  end

  def create
    solr_document = find_solr_document(params['document_url'])
    not_found && return unless solr_document

    @download_url = create_download_url(solr_document)
    respond_to do |format|
      if @download_url.save
        format.html { redirect_to @download_url, notice: I18n.t('download_urls.create.success') }
      else
        format.html { render :new }
      end
    end
  end

  def update # rubocop:disable Metrics/AbcSize
    @download_url = DownloadUrl.find(params[:id])
    if params[:state] == 'disable'
      if @download_url&.enabled?
        @download_url.enabled = false
        @download_url.save!
        redirect_back fallback_location: download_urls_url,
                      notice: "Download URL token \"#{@download_url.token}\" was disabled"
      end
    else
      # this shouldn't happen in the normal course of navigating through the site
      Rails.logger.error "Unknown state requested: #{params[:state]}"
      redirect_back fallback_location: download_urls_url, error: 'Bad request error'
    end
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

    def create_download_url(solr_document)
      @download_url = DownloadUrl.new(download_url_params)
      @download_url.url = solr_document[:id]
      @download_url.mime_type = solr_document[:mime_type]
      @download_url.creator = real_user.cas_directory_id
      @download_url.enabled = true
      @download_url.expires_at = 7.days.from_now
      # Title is not a form parameter, so we have to re-create it in order
      # for it to saved to the model
      @download_url.title = create_default_title(solr_document)
      @download_url
    end

    # Removes "enabled_eq" if it is 0.
    def query_params
      return if params.blank?

      rq_params = params[:rq]
      rq_params&.delete_if { |key, value| key == 'enabled_eq' && value == '0' }
    end
end

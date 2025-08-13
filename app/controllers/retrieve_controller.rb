# frozen_string_literal: true

class RetrieveController < ApplicationController
  skip_before_action :authenticate

  # GET /retrieve/:token
  def retrieve
    @token = params['token']
    @download_url = DownloadUrl.find_by(token: @token)

    return unless verify_download_url?(@download_url)

    render 'retrieve', layout: 'retrieve'
  end

  def do_retrieve # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    @token = params['token']
    download_url = DownloadUrl.find_by(token: @token)
    return unless verify_download_url?(download_url)

    response = ResourceService.get(download_url.url)
    data = response.body

    download_url.enabled = false
    download_url.accessed_at = Time.zone.now
    download_url.request_ip = request.ip
    download_url.request_user_agent = request.user_agent
    download_url.save

    headers['Content-Type'] = download_url.mime_type
    headers['Content-disposition'] = response['Content-Disposition']
    headers['Cache-Control'] ||= 'no-cache'
    headers.delete('Content-Length')
    headers['Content-Length'] = response['Content-Length']

    self.response_body = data

    # This download time is only approximate, and will likely be inaccurate
    # for large downloads.
    download_url.download_completed_at = Time.zone.now
    download_url.save
  end

  private

    def verify_download_url?(download_url) # rubocop:disable Metrics/MethodLength
      not_found unless download_url
      unless download_url.enabled?
        render 'disabled', layout: 'retrieve', status: :gone
        return false
      end

      if download_url.expired?
        # Disable the URL is the expiration date has passed
        if download_url.enabled?
          download_url.enabled = false
          download_url.save
        end
        @download_url = download_url
        render 'expired', layout: 'retrieve', status: :gone
        return false
      end
      true
    end
end

class RetrieveController < ApplicationController
  skip_before_action :authenticate

  # GET /retrieve/:token
  def retrieve
    @token = params['token']
    download_url = DownloadUrl.find_by(token: @token)

    return unless verify_download_url(download_url)

    render 'retrieve', layout: false
  end

  def do_retrieve # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    @token = params['token']
    download_url = DownloadUrl.find_by(token: @token)
    return unless verify_download_url(download_url)

    download_url.enabled = false
    download_url.accessed_at = Time.zone.now
    download_url.request_ip = request.ip
    download_url.request_user_agent = request.user_agent
    download_url.save

    fedora_url = download_url.url

    # Use Kernel explicity so that we can mock it in tests
    web_contents = Kernel.open(fedora_url, &:read)

    send_data web_contents,
              filename: 'foo', # TODO: figure out a real filename
              type: download_url.mime_type
    download_url.download_completed_at = Time.zone.now
    download_url.save
  end

  private

    def verify_download_url(download_url) # rubocop:disable Metrics/MethodLength
      not_found unless download_url
      unless download_url.enabled?
        render 'disabled', layout: false
        return false
      end

      if download_url.expired?
        # Disable the URL is the expiration date has passed
        if download_url.enabled?
          download_url.enabled = false
          download_url.save
        end
        render 'expired', layout: false
        return false
      end
      true
    end
end

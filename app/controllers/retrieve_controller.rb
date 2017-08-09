class RetrieveController < ApplicationController
  # GET /retrieve/:token
  def retrieve
    @token = params['token']
    download_url = DownloadUrl.find_by(token: @token)

    render 'retrieve' if verify_download_url(download_url, Time.now)
  end

  def do_retrieve
    @token = params['token']
    download_url = DownloadUrl.find_by(token: @token)
    verify_download_url(download_url, Time.now)
    download_url.enabled = false
    download_url.accessed_at = Time.now
    download_url.request_ip = request.ip
    download_url.request_user_agent = request.user_agent
    download_url.save

    fedora_url = download_url.url

    # Use OpenURI explicity so that we can mock it in tests
    web_contents = OpenURI.open(fedora_url) {|f| f.read }

    send_data web_contents,
              filename: "foo",
              type: download_url.mimetype
    download_url.download_completed_at = Time.now
    download_url.save
  end

  private

    def verify_download_url(download_url, current_time)
      not_found unless download_url
      unless download_url.enabled?
        render 'disabled', layout: false
        return false
      end
      true
    end

end

json.extract! download_url, :id, :token, :url, :title, :notes, :mime_type,
              :creator, :enabled, :request_ip, :request_user_agent,
              :accessed_at, :download_completed_at, :created_at, :updated_at
json.url download_url_url(download_url, format: :json)

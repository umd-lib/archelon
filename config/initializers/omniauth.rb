# OmniAuth CAS Strategy initializer

# UMD CAS base URL
CAS_URL = "https://login.umd.edu/cas"

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :cas, url: CAS_URL
end

OmniAuth.config.logger = Rails.logger

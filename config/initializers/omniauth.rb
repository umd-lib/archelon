# OmniAuth CAS Strategy initializer

# UMD CAS base URL
CAS_URL = "https://login.umd.edu/cas"

Rails.application.config.middleware.use OmniAuth::Builder do
  if CasHelper.use_developer_login
    provider :developer, fields: [:uid], uid_field: :uid
  else
    provider :cas, url: CAS_URL
  end
end

OmniAuth.config.logger = Rails.logger

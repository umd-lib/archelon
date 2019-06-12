# OmniAuth CAS Strategy initializer
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :cas, url: Rails.application.config.cas_url
end

OmniAuth.config.logger = Rails.logger 
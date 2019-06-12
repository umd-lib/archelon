# OmniAuth CAS Strategy initializer
Rails.application.config.middleware.use OmniAuth::Builder do
    provider :cas, url: "https://login.umd.edu/cas"
end

OmniAuth.config.logger = Rails.logger 
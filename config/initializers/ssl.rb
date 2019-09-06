# Configures an SSL context for use with HTTPS connections

# Load the configuration
template = ERB.new File.new("#{Rails.root}/config/ssl.yml").read
SSL_CONFIG = YAML.load(template.result(binding))[Rails.env]

SSL_CONTEXT = OpenSSL::SSL::SSLContext.new

SSL_CONTEXT.verify_mode = SSL_CONFIG['verify_mode']
SSL_CONTEXT.ca_file = SSL_CONFIG['ca_file'] if SSL_CONFIG['ca_file']

SSL_CONFIG['client_certs'].each do |config|
  SSL_CONTEXT.add_certificate(
    OpenSSL::X509::Certificate.new(File.read(config['cert'])),
    OpenSSL::PKey.read(File.read(config['key']))
  )
end

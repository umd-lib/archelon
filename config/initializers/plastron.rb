PLASTRON_REST_BASE_URL=ENV['PLASTRON_REST_BASE_URL']
PLASTRON_PUBLIC_KEY = ENV['PLASTRON_PUBLIC_KEY']

# register JSON Problem Details (RFC 9457) to parse as standard JSON
HTTP::MimeType.register_adapter 'application/problem+json', HTTP::MimeType::JSON

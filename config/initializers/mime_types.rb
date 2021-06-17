# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf

Mime::Type.register 'text/turtle', :ttl
Mime::Type.register 'application/n-triples', :nt

# Add new mime types for files in "public" directory
# See https://stackoverflow.com/a/45470372
Rack::Mime::MIME_TYPES[".ttl"]="text/turtle"
Rack::Mime::MIME_TYPES[".nt"]="application/n-triples"
Rack::Mime::MIME_TYPES[".json"]="application/json-ld"

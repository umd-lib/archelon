require 'addressable/template'

IIIF_VIEWER_URL_TEMPLATE = Addressable::Template.new(ENV['IIIF_VIEWER_URL_TEMPLATE'])
IIIF_MANIFESTS_URL_TEMPLATE = Addressable::Template.new(ENV['IIIF_MANIFESTS_URL_TEMPLATE'])

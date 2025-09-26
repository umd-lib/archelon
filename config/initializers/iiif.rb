require 'addressable/template'

IIIF_VIEWER_URL_TEMPLATE = Addressable::Template.new(ENV['IIIF_VIEWER_URL_TEMPLATE'])

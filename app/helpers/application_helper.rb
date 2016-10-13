require "erb"

module ApplicationHelper
  FEDORA_BASE_URL = Rails.application.config.fcrepo_base_url
  IIIF_MANIFEST_PREFIX = Rails.application.config.iiif_manifest_url
  FEDORA_BINARY = "http://fedora.info/definitions/v4/repository#Binary"
  ALLOWED_MIME_TYPES = ["image/jpeg", "image/tiff", "image/jp2"]

  def is_mirador_displayable(document)
    return true
    document._source[:rdf_type].include? FEDORA_BINARY and ALLOWED_MIME_TYPES.include? document._source[:mime_type]
  end

  def iiif_manifest_url(document)
    id = document._source[:id]
    id.slice!(FEDORA_BASE_URL)
    iiif_url = IIIF_MANIFEST_PREFIX + ERB::Util.url_encode(id)
    return iiif_url
  end
end

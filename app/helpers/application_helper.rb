require "erb"

module ApplicationHelper
  FEDORA_BASE_URL = Rails.application.config.fcrepo_base_url
  IIIF_MANIFEST_PREFIX = Rails.application.config.iiif_manifest_url
  PCDM_OBJECT = 'pcdm:Object'
  PCDM_FILE = 'pcdm:File'
  ALLOWED_MIME_TYPE = 'image/tiff'

  def is_mirador_displayable(document)
    rdf_types = document._source[:rdf_type];
    if rdf_types.include? PCDM_OBJECT
      return true
    elsif document._source[:rdf_type].include? PCDM_FILE and (ALLOWED_MIME_TYPE == document._source[:mime_type])
      return true
    else
      return false
    end
  end

  def encoded_id(document)
    id = document._source[:id]
    id.slice!(FEDORA_BASE_URL)
    return ERB::Util.url_encode(id)
  end

  def iiif_base_url()
    return IIIF_MANIFEST_PREFIX
  end
end

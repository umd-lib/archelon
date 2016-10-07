module ApplicationHelper
  FEDORA_BASE_URL = "https://fcrepolocal/fcrepo/rest/tmp/"
  IIIF_URL_PREFIX = "https://iiiflocal/images/"
  IIIF_URL_SUFFIX = "/full/full/0/default.jpg"
  FEDORA_BINARY = "http://fedora.info/definitions/v4/repository#Binary"
  ALLOWED_MIME_TYPES = ["image/jpeg", "image/tiff", "image/jp2"]

  def is_mirador_displayable(document)
    document._source[:rdf_type].include? FEDORA_BINARY and ALLOWED_MIME_TYPES.include? document._source[:mime_type]
  end

  def mirador_link(id)
    puts id
    sliced = id.slice!(FEDORA_BASE_URL)
    puts sliced
    puts id
    iiif_url = IIIF_URL_PREFIX + id + IIIF_URL_SUFFIX
  end
end

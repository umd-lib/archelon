require "erb"

module ApplicationHelper
  FEDORA_BASE_URL = Rails.application.config.fcrepo_base_url
  IIIF_BASE_URL = Rails.application.config.iiif_base_url
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
    return ERB::Util.url_encode(id.slice(FEDORA_BASE_URL.size, id.size))
  end

  def iiif_base_url()
    return IIIF_BASE_URL
  end

  def from_subquery(subquery_field, args)
    args[:document][args[:field]] = args[:document][subquery_field]['docs']
  end

  def collection_from_subquery(args)
    from_subquery 'pcdm_collection_info', args
  end

  def parent_from_subquery(args)
    from_subquery 'pcdm_member_of_info', args
  end

  def members_from_subquery(args)
    from_subquery 'pcdm_members_info', args
  end

  def file_parent_from_subquery(args)
    from_subquery 'pcdm_file_of_info', args
  end

  def files_from_subquery(args)
    from_subquery 'pcdm_files_info', args
  end

  def related_objects_from_subquery(args)
    from_subquery 'pcdm_related_objects_info', args
  end

  def related_object_of_from_subquery(args)
    from_subquery 'pcdm_related_object_of_info', args
  end

  def rdf_type_list(args)
    args[:document][args[:field]]
  end

  def fcrepo_url
    FEDORA_BASE_URL.sub(/fcrepo\/rest\/?/, "")
  end

  def view_in_fedora_link(document)
    url = document[:id]
    url += '/fcr:metadata' if document[:rdf_type].include? 'fedora:Binary'
    link_to 'View in Fedora', url, target: '_blank'
  end
end

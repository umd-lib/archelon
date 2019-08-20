# frozen_string_literal: true

require 'erb'
require 'addressable/template'

module ApplicationHelper
  FEDORA_BASE_URL = Rails.application.config.fcrepo_base_url
  IIIF_BASE_URL = Rails.application.config.iiif_base_url
  PCDM_OBJECT = 'pcdm:Object'
  PCDM_FILE = 'pcdm:File'
  ALLOWED_MIME_TYPE = 'image/tiff'
  MIRADOR_STATIC_VERSION = Rails.application.config.mirador_static_version

  def mirador_displayable?(document)
    rdf_types = document._source[:rdf_type]
    component = document._source[:component]
    return true if rdf_types.include?(PCDM_OBJECT) && (component != 'Article')

    false
  end

  def encoded_id(document)
    id = document._source[:id]
    ERB::Util.url_encode(id.slice(FEDORA_BASE_URL.size, id.size))
  end

  def repo_path(url)
    url.slice(FEDORA_BASE_URL.size, url.size)
  end

  def iiif_base_url
    IIIF_BASE_URL
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

  def annotation_source_from_subquery(args)
    from_subquery 'annotation_source_info', args
  end

  def rdf_type_list(args)
    args[:document][args[:field]]
  end

  def unique_component_types(pcdm_members_info)
    pcdm_members_info.map { |member| member['component'] }.uniq
  end

  def fcrepo_url
    FEDORA_BASE_URL.sub(%r{fcrepo/rest/?}, '')
  end

  def view_in_fedora_link(document)
    url = document[:id]
    url += '/fcr:metadata' if document[:rdf_type].include? 'fedora:Binary'
    link_to 'View in Fedora', url, target: '_blank'
  end

  def link_to_document_view(args)
    value = args[:value]
    value = [value] unless value.is_a? Array
    safe_join(value.map { |v| link_to v, solr_document_path(v) }, ', ')
  end

  def generate_download_url_link(document)
    url = document[:id]
    link_to 'Generate Download URL', generate_download_url_path(document_url: url)
  end

  def format_extracted_text(args)
    if args[:value].is_a? Array
      args[:value].map { |v| format_extracted_text(value: v) }.join('... ').html_safe # rubocop:disable Rails/OutputSafety, Metrics/LineLength - I assume the .html_safe is intended
    else
      # to strip out the embedded word corrdinates
      coord_pattern = /\|\d+,\d+,\d+,\d+/
      # to remove {SOFT HYPHEN}{NEWLINE}
      hyphen_pattern = /\u{AD}\n/
      args[:value].gsub(coord_pattern, '').gsub(hyphen_pattern, '')
    end
  end

  # remove the pairtree from the path
  def compress_path(path)
    path.tr('/', ':').gsub(/:(..):(..):(..):(..):\1\2\3\4/, '::\1\2\3\4')
  end

  def mirador_viewer_url(document, query)
    template = Addressable::Template.new(
      "#{IIIF_BASE_URL}viewer{/version}/mirador.html?manifest=fcrepo:{+id}{&iiifURLPrefix,q}"
    )
    template.expand(
      version: MIRADOR_STATIC_VERSION,
      id: compress_path(repo_path(document[:id])),
      iiifURLPrefix: "#{IIIF_BASE_URL}manifests/",
      q: query
    ).to_s
  end
end

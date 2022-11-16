# frozen_string_literal: true

# UMD Customization
require 'erb'
require 'addressable/template'

LABEL_PREDICATE = 'http://www.w3.org/2000/01/rdf-schema#label'
SAME_AS_PREDICATE = 'http://www.w3.org/2002/07/owl#sameAs'
# End UMD Customization

module ApplicationHelper
  # UMD Customization
  def encoded_id(document)
    id = document._source[:id]
    ERB::Util.url_encode(id.slice(FCREPO_BASE_URL.size, id.size))
  end

  def repo_path(url)
    url.slice(REPO_EXTERNAL_URL.size, url.size)
  end

  def fcrepo_url
    FCREPO_BASE_URL.sub(%r{fcrepo/rest/?}, '')
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
      args[:value].map { |v| format_extracted_text(value: v) }.join('... ').html_safe # rubocop:disable Rails/OutputSafety -- I assume the .html_safe is intended
    else
      # to strip out the embedded word coordinates
      coord_pattern = /\|\d+,\d+,\d+,\d+/
      # to remove {SOFT HYPHEN}{NEWLINE}
      hyphen_pattern = /\u{AD}\n/
      args[:value].gsub(coord_pattern, '').gsub(hyphen_pattern, '')
    end
  end

  def iiif_id(repo_uri)
    "fcrepo:#{repo_path(repo_uri).tr('/', ':')}"
  end

  def iiif_manifest_url(repo_uri)
    IIIF_MANIFESTS_URL_TEMPLATE.expand(manifest_id: iiif_id(repo_uri)).to_s
  end

  def iiif_viewer_url(repo_uri, query)
    IIIF_VIEWER_URL_TEMPLATE.expand(manifest: iiif_manifest_url(repo_uri), q: query).to_s
  end

  def link_to_edit(resource)
    return unless can? :edit, resource

    link_to 'Edit', resource_edit_path(resource), class: 'btn btn-sm btn-success'
  end

  def link_to_delete(resource)
    return unless can? :destroy, resource

    link_to 'Delete', resource, method: :delete, data: { confirm: 'Are you sure?' }, class: 'btn btn-sm btn-danger'
  end

  def language_badge(node)
    content_tag :span, node['@language'], class: 'badge badge-light', style: 'background: #ddd; color: #333'
  end

  def datatype_badge(node)
    link_to node['@type'], node['@type'], class: 'badge badge-light', style: 'background: #ddd; color: #333'
  end

  def display_node(node, field, items) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength
    return display_handle(node) if field[:datatype] == 'http://vocab.lib.umd.edu/datatype#handle'

    if node.key? '@value'
      content = content_tag :span, node['@value']
      content << ' ' << language_badge(node) if node.key? '@language'
      content << ' ' << datatype_badge(node) if node.key? '@type'
      content
    elsif node.key? '@id'
      uri = node['@id']
      if items.key? uri
        # labeled thing display
        obj = items[uri]
        label = obj[LABEL_PREDICATE]&.first
        same_as = obj[SAME_AS_PREDICATE]&.first
        if same_as
          content = display_node(label, field, obj)
          content << ' → ' << link_to(same_as['@id'], same_as['@id'])
        else
          content_tag :span, display_node(label, field, obj)
        end
      elsif field[:vocab]
        vocab = VocabularyService.get_vocabulary(field[:vocab])
        # fall back to displaying the URI if the vocab isn't defined on this server
        return link_to uri, uri unless vocab.terms?

        term = vocab.term(uri)
        # fall back to displaying the URI if can't find the term
        return link_to uri, uri if term.nil?

        content = content_tag :span, term.label
        content << ' → ' << link_to(term.same_as, term.same_as) if term.same_as
        content
      else
        link_to uri, uri
      end
    else
      node
    end
  end

  def max_bookmarks_selection_limit
    1000
  end

  # Display formatting for the "handle" field
  def display_handle(node)
    handle_value = node['@value'].delete_prefix('hdl:')

    content = content_tag :span, handle_value

    if ENV['HANDLE_HTTP_PROXY_BASE'].present?
      handle_server_base_url = ENV['HANDLE_HTTP_PROXY_BASE']
      handle_url = URI.join(handle_server_base_url, handle_value).to_s
      content << ' - ' << link_to(handle_url, handle_url) << ''
    end

    content
  end
  # End UMD Customization
end

# frozen_string_literal: true

#
# URL helper methods
module UrlHelper
  include Blacklight::UrlHelperBehavior

  # link_to_document(doc, 'VIEW', :counter => 3)
  # Overrides the Blacklight default behavior in order to not include the '/track' url suffix in the results view.
  # The /track url do not work with constraints: { id: /.*/ } configured in the routes.rb
  def link_to_document(doc, field_or_opts = nil, opts = { counter: nil }) # rubocop:disable Metrics/MethodLength
    if field_or_opts.is_a? Hash
      opts = field_or_opts
    else
      field = field_or_opts
    end

    if doc[:rdf_type].include?('oa:Annotation')
      link_to_annotation_pages(doc)
    else
      field ||= document_show_link_field(doc)
      label = index_presenter(doc).label field, opts
      link_to label, url_for_document(doc), opts
    end
  end

  def link_to_annotation_pages(doc)
    return unless doc[:annotation_source_info] && doc[:annotation_source_info][:docs]
    pages = doc[:annotation_source_info][:docs]
    safe_join(pages.map { |page| link_to page[:display_title], solr_document_path(page[:id], q: @current_query) }, ', ')
  end
end

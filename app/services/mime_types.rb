# frozen_string_literal: true

# Utility to retrive MIME types from Solr
class MimeTypes
  include Blacklight::Configurable

  QUERY = {
    q: '*:*',
    facet: 'on',
    'facet.field': 'mime_type',
    'facet.limit': '-1',
    rows: '0'
  }.freeze

  # Queries Solr and returns an array of Strings representing the MIME types
  def self.mime_types
    solr = Blacklight::Solr::Repository.new(blacklight_config)
    process_solr_response(solr.search(QUERY))
  end

  # Processes the Solr response, returning an array of Strings
  def self.process_solr_response(solr_response)
    mime_types_with_count = solr_response.dig('facet_counts', 'facet_fields', 'mime_type')
    mime_types = mime_types_with_count.each_slice(2).map(&:first)
    mime_types
  end
end

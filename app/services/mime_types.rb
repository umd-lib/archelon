# frozen_string_literal: true

# Utility to retrieve MIME types from Solr
class MimeTypes < SolrQueryService
  QUERY = {
    q: '*:*',
    indent: 'on',
    rows: '1000',
    fl: 'id,file__mime_type__id,item__has_member,page__has_file,[child]',
    'facet': 'on',
    'facet.field': 'file__mime_type__id'
  }.freeze

  # Queries Solr and returns an array of Strings representing the MIME types
  def self.mime_types(uris)
    solr = Blacklight::Solr::Repository.new(blacklight_config)
    query = query(uris)
    process_solr_response(solr.search(query))
  end

  def self.query(uris)
    QUERY.merge 'fq': match_any('id', uris)
  end

  # Returns an array of Strings
  def self.process_solr_response(solr_response) # rubocop:disable Metrics/MethodLength
  # With the new Solr Index we can facet for mime_types
  # We'll get a key like this in the response:
  #
  # "facet_counts":{
  #   "facet_queries":{ },
  #   "facet_fields":{
  #     "file__mime_type__id":["image/tiff",0,"text/xml",0]
  #   },
  #   "facet_ranges":{ },
  #   "facet_intervals":{ },
  #   "facet_heatmaps":{ }
  # }

  # We can just return the strings from the list to get all the unique mime_types found
    mime_facet_fields = solr_response.dig('response', 'facet_counts', 'facet_fields', 'file__mime_type__id')
    mime_facet_fields.select { |val| val.is_a ? String }.sort.to_a
  end
end

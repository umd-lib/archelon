# frozen_string_literal: true

# Utility to retrieve MIME types from Solr
class MimeTypes < SolrQueryService
  QUERY = {
    q: '*:*',
    indent: 'on',
    rows: '1000',
    fl: 'id,files:[subquery]',
    'files.q': '{!terms f=pcdm_file_of v=$row.pcdm_members}',
    'files.fl': 'mime_type',
    'files.rows': '1000',
    'facet': 'on',
    'facet.field': 'mime_type'
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

  # Processes the Solr response, returning an array of Strings
  def self.process_solr_response(solr_response) # rubocop:disable Metrics/MethodLength
    # This method is a bit of a kludge, because it's not clear how to get the
    # facet list directly from a Solr query. This brute-force method iterates
    # through all the files in the response, generating a set of all the
    # "mime_type" fields encountered, and then converts it to an array.
    docs = solr_response.dig('response', 'docs')

    mime_set = Set[]
    docs.each do |doc|
      file_docs = doc.dig('files', 'docs')
      file_docs.each do |file_doc|
        mime_type = file_doc['mime_type']
        mime_set << mime_type
      end
    end

    mime_types = mime_set.sort.to_a
    mime_types
  end
end

# frozen_string_literal: true

# Utility to get binary counts and sizes for items
class BinariesStats < SolrQueryService
  QUERY = {
    q: '*:*',
    rows: '10000',
    'files.q': '{!terms f=pcdm_file_of v=$row.pcdm_members}',
    indent: 'on',
    fl: 'id,pcdm_members,files:[subquery]',
    'files.fl': 'id,size',
    'files.rows': '10000'
  }.freeze

  def self.query(uris, mime_types)
    fq = QUERY.merge 'fq': match_any('id', uris)
    fq = fq.merge 'files.fq': match_any('mime_type', mime_types) if mime_types
    fq
  end

  def self.get_stats(uris, mime_types)
    solr = Blacklight::Solr::Repository.new(blacklight_config)
    process_solr_response(solr.search(query(uris, mime_types)))
  end

  def self.process_solr_response(solr_response)
    solr_docs = solr_response['response']['docs']

    binary_sizes = solr_docs.map do |doc|
      doc['files']['docs'].map { |f| f['size'].to_i }.sum
    end
    binary_counts = solr_docs.map { |doc| doc['files']['numFound'] }

    {
      count: binary_counts.sum,
      total_size: binary_sizes.sum
    }
  end
end

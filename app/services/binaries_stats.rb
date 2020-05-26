# frozen_string_literal: true

# Utility to get binary counts and sizes for items
class BinariesStats
  include Blacklight::Configurable

  QUERY = {
    q: '*:*',
    'pages.fq': 'component:Page',
    'files.q': '{!terms f=pcdm_file_of v=$row.pcdm_members}',
    indent: 'on',
    fl: 'id,pages:[subquery],files:[subquery]',
    'files.fl': 'id,size',
    'files.rows': '10000',
    'pages.rows': '0',
    'pages.q': '{!terms f=id v=$row.pcdm_members}'
  }.freeze

  def self.query(uris)
    QUERY.merge 'fq': uris.map { |uri| "id:\"#{uri}\"" }.join(' OR ')
  end

  def self.get_stats(uris)
    solr = Blacklight::Solr::Repository.new(blacklight_config)
    process_solr_response(solr.search(query(uris)))
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

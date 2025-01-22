# frozen_string_literal: true

# Utility to get binary counts and sizes for items
class BinariesStats < SolrQueryService
  QUERY = {
    q: '*:*',
    rows: '10000',
    indent: 'on',
    fl: 'id,file__size__int,item__has_member,page__has_file,[child]',
  }.freeze

  def self.query(uris, mime_types)
    fq = QUERY.merge 'fq': match_any('id', uris)
    fq
  end

  def self.get_stats(uris, mime_types)
    solr = Blacklight::Solr::Repository.new(blacklight_config)
    process_solr_response(solr.search(query(uris, mime_types)))
  end

  def self.process_solr_response(solr_response)
    docs = solr_response.dig('response','docs')

    binary_sizes = docs.map do |doc|
      file = doc.dig('item__has_member','page__has_file')
      file.map { |f| f['file__size__int'].to_i }.sum
    end

    binary_counts = docs.map do |doc|
      file = doc.dig('item__has_member','page__has_file')
      file.length()

    {
      count: binary_counts.sum,
      total_size: binary_sizes.sum
    }
  end
end

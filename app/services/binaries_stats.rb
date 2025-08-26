# frozen_string_literal: true

# Utility to get binary counts and sizes for items
class BinariesStats < SolrQueryService
  QUERY = {
    q: '*:*',
    rows: '10000',
    indent: 'on',
    'files.rows': '10000'
  }.freeze

  def self.query(uris)
    QUERY.merge fq: match_any('id', uris)
  end

  def self.get_stats(uris, mime_types)
    solr = Blacklight::Solr::Repository.new(blacklight_config)
    process_solr_response(solr.search(query(uris)), mime_types)
  end

  def self.process_solr_response(solr_response, mime_types) # rubocop:disable Metrics/MethodLength
    docs = solr_response.fetch('response', {}).fetch('docs', [])
    binary_counts = 0
    binary_sizes = 0

    docs.each do |doc|
      object_has_members = doc.fetch('object__has_member', [])
      object_has_members.each do |obj|
        page_has_files = obj.fetch('page__has_file', [])
        page_has_files.each do |page|
          mime_type = page.fetch('file__mime_type__str', nil)
          if mime_types.include?(mime_type)
            binary_counts += 1
            binary_sizes += page.fetch('file__size__int', '0').to_i
          end
        end
      end
    end

    {
      count: binary_counts,
      total_size: binary_sizes
    }
  end
end

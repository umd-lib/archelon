# frozen_string_literal: true

# Utility to retrieve MIME types from Solr
#
# Expected Solr response has the form
# { response:
#   { docs:
#     [
#       { object_had_members:
#         [
#           { page_has_files:
#             [
#               { mime_types: '<MIME_TYPE>', ... },
#                ...
#             ]
#           }
#         ]
#       }
#     ]
#   }
# }
class MimeTypes < SolrQueryService
  QUERY = {
    q: '*:*',
    indent: 'on',
    rows: '1000'
  }.freeze

  # Queries Solr and returns an array of Strings representing the MIME types
  def self.mime_types(uris)
    solr = Blacklight::Solr::Repository.new(blacklight_config)
    query = query(uris)
    process_solr_response(solr.search(query))
  end

  def self.query(uris)
    QUERY.merge fq: match_any('id', uris)
  end

  # Processes the Solr response, returning an array of Strings representing the
  # unique MIME types of the files, sorted alphabetically
  def self.process_solr_response(solr_response) # rubocop:disable Metrics/MethodLength
    mime_set = Set[]
    docs = solr_response.fetch('response', {}).fetch('docs', [])
    docs.each do |doc|
      object_has_members = doc.fetch('object__has_member', [])
      object_has_members.each do |obj|
        page_has_files = obj.fetch('page__has_file', [])
        page_has_files.each do |page|
          mime_set << page.fetch('file__mime_type__str', nil)
        end
      end
    end
    mime_set.compact.sort.to_a
  end
end

# frozen_string_literal: true

# Utility for retrieve the list of repository collections from Solr
class RepositoryCollections
  include Blacklight::Configurable

  # Returns a Array of hashes, containing "display_name" and "uri" keys, sorted
  # by "display_name", corresponding to the "component:Collection" documents
  # in Solr.
  #
  # Raises Blacklight::Exceptions::ECONNREFUSED if Solr is not reachable, and
  # Blacklight::Exceptions::InvalidRequest if the Solr request is invalid\
  def self.list
    solr = Blacklight::Solr::Repository.new(blacklight_config)

    solr_response = solr.search fq: 'component:Collection', qt: '/select', q: '*:*'
    process_solr_response(solr_response)
  end

  # Converts a Solr response into an array of hashes, containing "uri" and
  # "display_title" fields.
  def self.process_solr_response(solr_response)
    collections = []
    solr_docs = solr_response['response']['docs']

    solr_docs.each do |doc|
      collection = {
        uri: doc['id'],
        display_title: doc['display_title']
      }

      collections.append collection
    end
    collections.sort_by { |c| c[:display_title] }
  end
end

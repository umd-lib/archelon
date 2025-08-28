# frozen_string_literal: true

# Utility for retrieve the list of repository collections from Solr
class AdminSetsService
  include Blacklight::Configurable

  # Returns a Array of hashes, containing "display_name" and "uri" keys, sorted
  # by "display_name", corresponding to the "component:Collection" documents
  # in Solr.
  #
  # Raises Blacklight::Exceptions::ECONNREFUSED if Solr is not reachable, and
  # Blacklight::Exceptions::InvalidRequest if the Solr request is invalid
  def self.list
    solr = Blacklight::Solr::Repository.new(blacklight_config)

    solr_response = solr.search fq: 'content_model_name__str:AdminSet', qt: '/select', q: '*:*', rows: 100
    process_solr_response(solr_response)
  end

  # Converts a Solr response into an array of hashes, containing "uri" and
  # "display_title" fields.
  def self.process_solr_response(solr_response)
    admin_sets = solr_response['response']['docs'].map do |doc|
      solr_doc = SolrDocument.new(doc)
      {
        uri: solr_doc['id'],
        display_title: solr_doc.display_titles
      }
    end
    admin_sets.sort_by { |c| c[:display_title] }
  end
end

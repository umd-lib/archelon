# frozen_string_literal: true

# Unpublish (delete) RDF serializations of a vocabulary
class UnpublishVocabularyRdfJob < ApplicationJob
  queue_as :default

  def perform(vocabulary)
    vocabulary.delete_published_rdf
  end
end

# frozen_string_literal: true

# Unpublish (delete) RDF serializations of a vocabulary
class UnpublishVocabularyRdfJob < ApplicationJob
  queue_as :default

  def perform(identifier)
    Vocabulary.delete_published_rdf identifier
  end
end

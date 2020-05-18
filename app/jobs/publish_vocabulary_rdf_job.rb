# frozen_string_literal: true

# Publish RDF representations of a vocabulary
class PublishVocabularyRdfJob < ApplicationJob
  queue_as :default

  def perform(vocabulary)
    vocabulary.publish_rdf
  end
end

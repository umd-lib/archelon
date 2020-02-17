# frozen_string_literal: true

# Publish RDF representations of a vocabulary
class PublishVocabularyRdfJob < ApplicationJob
  queue_as :default

  def perform(vocabulary, *formats)
    formats.each do |format|
      vocabulary.publish_rdf format.to_sym
    end
  end
end

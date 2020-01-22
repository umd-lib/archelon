# frozen_string_literal: true

# A controlled vocabulary that can contain types and individuals.
class Vocabulary < ApplicationRecord
  validates :name, presence: true, format: { with: /\A[a-z][a-zA-Z0-9_-]*\z/ }

  has_many :types, dependent: :destroy
  has_many :individuals, dependent: :destroy

  def uri
    "http://vocab.lib.umd.edu/#{name}\#"
  end

  def term_count
    types.count + individuals.count
  end

  def graph
    RDF::Graph.new.tap do |graph|
      add_types_to graph
      add_individuals_to graph
    end
  end

  private

    def add_types_to(graph)
      types.each do |type|
        type_uri = RDF::URI(type.uri)
        graph << [type_uri, RDF.type, RDF::RDFS.Class]
      end
    end

    def add_individuals_to(graph)
      individuals.each do |individual|
        individual_uri = RDF::URI(individual.uri)
        graph << [individual_uri, RDF::RDFS.label, individual.label]
        graph << [individual_uri, RDF::OWL.sameAs, RDF::URI(individual.same_as)] unless individual.same_as.empty?
      end
    end
end

# frozen_string_literal: true

# A controlled vocabulary that can contain types and individuals.
class Vocabulary < ApplicationRecord
  PREFIXES = {
    owl: RDF::OWL,
    rdfs: RDF::RDFS
  }.freeze

  FORMAT_EXTENSIONS = {
    jsonld: 'json',
    ttl: 'ttl',
    ntriples: 'nt'
  }.freeze

  VOCAB_CONTEXT = 'http://vocab.lib.umd.edu/'

  validates :identifier,
            presence: true,
            format: { with: /\A[a-z][a-zA-Z0-9_-]*\z/ },
            uniqueness: {
              message: lambda do |_object, data|
                "\"#{data[:value]}\" is already used by another vocabulary"
              end
            }

  has_many :types, dependent: :destroy
  has_many :individuals, dependent: :destroy

  def uri
    VOCAB_CONTEXT + identifier + '#'
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

  def publish_rdf(format)
    FORMAT_EXTENSIONS.include?(format) || raise('Unrecognized format')

    vocab_dir = Rails.root.join('public', 'vocabularies')
    FileUtils.makedirs vocab_dir

    extension = FORMAT_EXTENSIONS[format]
    path = Rails.root.join(vocab_dir, "#{identifier}.#{extension}")
    File.open(path, 'w') { |f| f << graph.dump(format, prefixes: PREFIXES.dup) }
  end

  def self.delete_published_rdf(identifier)
    vocab_dir = Rails.root.join('public', 'vocabularies')
    Dir.glob(Rails.root.join(vocab_dir, "#{identifier}.*")).each do |file|
      FileUtils.safe_unlink file
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
        graph << [individual_uri, RDF::OWL.sameAs, RDF::URI(individual.same_as)] if individual.same_as.present?
      end
    end
end

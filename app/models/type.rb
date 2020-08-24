# frozen_string_literal: true

# A type (RDF class) entity in a vocabulary
class Type < ApplicationRecord
  validates :identifier,
            presence: true,
            format: { with: /\A[A-Z][a-zA-Z0-9_-]*\z/ },
            uniqueness: {
              scope: :vocabulary,
              message: lambda do |object, data|
                "\"#{data[:value]}\" is already used in the #{object.vocabulary.identifier} vocabulary"
              end
            }
  belongs_to :vocabulary

  after_save ->(type) { type.vocabulary.publish_rdf_async }
  after_destroy ->(type) { type.vocabulary.publish_rdf_async }

  def uri
    vocabulary.uri + identifier
  end

  def label
    identifier
  end

  def same_as
    nil
  end
end

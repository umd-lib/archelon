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

  def uri
    vocabulary.uri + identifier
  end
end

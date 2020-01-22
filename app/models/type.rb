# frozen_string_literal: true

# A type (RDF class) entity in a vocabulary
class Type < ApplicationRecord
  validates :name, presence: true, format: { with: /\A[A-Z][a-zA-Z0-9_-]*\z/ }
  belongs_to :vocabulary

  def uri
    vocabulary.uri + name
  end
end

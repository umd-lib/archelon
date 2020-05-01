# frozen_string_literal: true

# A datatype entity in a vocabulary.
class Datatype < ApplicationRecord
  validates :identifier,
            presence: true,
            format: { with: /\A[a-zA-Z0-9][a-zA-Z0-9_-]*\z/ },
            uniqueness: {
              scope: :vocabulary,
              message: lambda do |object, data|
                "\"#{data[:value]}\" is already used in the #{object.vocabulary.identifier} vocabulary"
              end
            }
  belongs_to :vocabulary

  after_save ->(datatype) { datatype.vocabulary.publish_rdf_async }
  after_destroy ->(datatype) { datatype.vocabulary.publish_rdf_async }

  def uri
    vocabulary.uri + identifier
  end
end

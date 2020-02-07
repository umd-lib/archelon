# frozen_string_literal: true

# An individual entity in a vocabulary.
class Individual < ApplicationRecord
  validates :identifier,
            presence: true,
            format: { with: /\A[a-zA-Z0-9][a-zA-Z0-9_-]*\z/ },
            uniqueness: {
              scope: :vocabulary,
              message: lambda do |object, data|
                "\"#{data[:value]}\" is already used in the #{object.vocabulary.identifier} vocabulary"
              end
            }
  validates :label, presence: true

  belongs_to :vocabulary

  def uri
    vocabulary.uri + identifier
  end
end

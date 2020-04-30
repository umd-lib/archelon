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
end

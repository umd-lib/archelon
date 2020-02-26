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

  def source
    return nil if same_as.blank?

    SAME_AS_ABBREVIATIONS.each do |prefix, abbreviation|
      return abbreviation if same_as.starts_with? prefix
    end
    nil
  end
end

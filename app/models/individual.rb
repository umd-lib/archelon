# frozen_string_literal: true

# An individual entity in a vocabulary.
class Individual < ApplicationRecord
  validates :identifier, presence: true, format: { with: /\A[a-zA-Z0-9][a-zA-Z0-9_-]*\z/ }
  validates :label, presence: true

  belongs_to :vocabulary

  def uri
    vocabulary.uri + identifier
  end
end

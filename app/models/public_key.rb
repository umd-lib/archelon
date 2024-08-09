# frozen_string_literal: true

# Public key
class PublicKey < ApplicationRecord
  belongs_to :cas_user
end

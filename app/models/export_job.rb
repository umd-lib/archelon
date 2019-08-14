# frozen_string_literal: true

# An export job from Fedora
class ExportJob < ApplicationRecord
  belongs_to :cas_user

  FORMATS = %w[CSV Turtle].freeze

  # statuses
  IN_PROGRESS = 'In Progress'
  READY = 'Ready'
  FAILED = 'Failed'

  STATUSES = [IN_PROGRESS, READY, FAILED].freeze
end

# frozen_string_literal: true

# An export job from Fedora
class ExportJob < ApplicationRecord
  belongs_to :cas_user

  CSV_FORMAT = 'text/csv'
  TURTLE_FORMAT = 'text/turtle'

  FORMATS = {
    CSV_FORMAT => 'CSV',
    TURTLE_FORMAT => 'Turtle'
  }.freeze

  FORMAT_EXTENSIONS = {
    CSV_FORMAT => '.csv',
    TURTLE_FORMAT => '.ttl'
  }.freeze

  # statuses
  IN_PROGRESS = 'In Progress'
  READY = 'Ready'
  FAILED = 'Failed'

  STATUSES = [IN_PROGRESS, READY, FAILED].freeze

  def filename
    name + FORMAT_EXTENSIONS[format]
  end
end

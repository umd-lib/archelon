# frozen_string_literal: true

# An export job from Fedora
class ExportJob < ApplicationRecord
  include PlastronStatus

  belongs_to :cas_user

  after_commit { ExportJobRelayJob.perform_later(self) }

  CSV_FORMAT = 'text/csv'
  TURTLE_FORMAT = 'text/turtle'

  FORMATS = {
    CSV_FORMAT => 'CSV',
    TURTLE_FORMAT => 'Turtle'
  }.freeze

  #  Maximum allowed binaries file size, in bytes
  MAX_ALLOWED_BINARIES_DOWNLOAD_SIZE = if ENV['MAX_ALLOWED_BINARIES_DOWNLOAD_SIZE']
                                         ENV['MAX_ALLOWED_BINARIES_DOWNLOAD_SIZE'].to_i
                                       else
                                         50.gigabytes
                                       end

  def self.exportable?(document)
    return false if document[:component].nil?

    # non-exportable types
    return false if %w[Collection Page Article].include? document[:component]

    # binaries are not directly exportable
    return false if document[:rdf_type].include? 'fedora:Binary'

    true
  end

  def filename
    name + '.zip'
  end

  def path
    File.join(EXPORT_CONFIG[:dir], filename)
  end

  def self.from_uri(uri)
    # assume that the last path segment of the uri is the identifier
    id = uri[uri.rindex('/') + 1..]
    find(id)
  end

  def update_progress(message)
    stats = message.body_json
    progress = (stats['count']['exported'].to_f / stats['count']['total'] * 100).round
    self.progress = progress
    save!
  end

  def update_status(message)
    self.plastron_status = message.headers['PlastronJobStatus']
    save!
  end

  # Returns a array of the selected MIME types for the job
  def selected_mime_types
    return [] if mime_types.blank?

    mime_types.split(',')
  end

  # Returns true if the job can be submitted, false otherwise
  def job_submission_allowed?
    !export_binaries || binaries_size.nil? || binaries_size <= MAX_ALLOWED_BINARIES_DOWNLOAD_SIZE
  end

  # Returns the maximum allowed binaries file size, in bytes
  def max_allowed_binaries_download_size
    MAX_ALLOWED_BINARIES_DOWNLOAD_SIZE
  end

  private

    def content_disposition(headers)
      Mechanize::HTTP::ContentDispositionParser.parse(headers[:content_disposition])
    end
end

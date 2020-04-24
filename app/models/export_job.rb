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

  FORMAT_EXTENSIONS = {
    CSV_FORMAT => '.csv',
    TURTLE_FORMAT => '.ttl',
    'application/zip' => '.zip'
  }.freeze

  def self.exportable_types
    %w[Image Issue Letter]
  end

  def download_file
    response = HTTP.get(download_url, ssl_context: SSL_CONTEXT)
    mime_type = response.content_type.mime_type
    [
      response.body,
      {
        type: mime_type,
        filename: filename(content_disposition(response.headers), mime_type)
      }
    ]
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
    self.download_url = message.body_json['download_uri']
    save!
  end

  private

    def content_disposition(headers)
      Mechanize::HTTP::ContentDispositionParser.parse(headers[:content_disposition])
    end

    def filename(content_disposition, mime_type)
      if content_disposition
        content_disposition.filename || name + FORMAT_EXTENSIONS[mime_type]
      else
        name + FORMAT_EXTENSIONS[mime_type]
      end
    end
end

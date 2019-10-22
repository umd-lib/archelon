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
    TURTLE_FORMAT => '.ttl',
    'application/zip' => '.zip'
  }.freeze

  # statuses
  IN_PROGRESS = 'In Progress'
  READY = 'Ready'
  FAILED = 'Failed'

  STATUSES = [IN_PROGRESS, READY, FAILED].freeze

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

  private

    def content_disposition(headers)
      return nil unless headers.key? :content_disposition

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

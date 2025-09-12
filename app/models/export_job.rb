# frozen_string_literal: true

# An export job from Fedora
class ExportJob < ApplicationRecord
  belongs_to :cas_user

  enum :state, {
    pending: 1,
    in_progress: 2,
    export_complete: 3,
    partial_export: 4,
    export_error: 5
  }

  after_commit :send_status_notification

  # If it has been more than IDLE_THRESHOLD since the last update time on this job,
  # and the job is in an active state, then consider it stalled.
  IDLE_THRESHOLD = 30.seconds

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
    "#{name}.zip"
  end

  def path
    File.join(EXPORT_CONFIG[:dir], filename)
  end

  def self.from_uri(uri)
    # assume that the last path segment of the uri is the identifier
    id = uri[(uri.rindex('/') + 1)..]
    find(id)
  end

  def update_progress(message)
    return if message.blank?

    stats = message.body_json
    progress = (stats['count']['exported'].to_f / stats['count']['total'] * 100).round
    self.progress = progress
    self.state = progress.positive? ? :in_progress : :pending
    save!
  end

  def update_status(message)
    self.state = message.job_state
    save!
  end

  def done?
    export_complete? || partial_export?
  end

  def downloadable?
    done? && File.exist?(path)
  end

  # Heuristic method to determine if this job might be stalled
  def stalled?
    # only makes sense for jobs that are in an actively processing state
    return false unless pending? || in_progress?

    (Time.zone.now - updated_at) > IDLE_THRESHOLD
  end

  # Generates status text display for the GUI
  def status_text
    return 'Unknown' if state.blank?

    return I18n.t("activerecord.attributes.export_job.status.#{state}") unless in_progress?

    I18n.t('activerecord.attributes.export_job.status.in_progress') + progress_text
  end

  def progress_text
    return '' unless !progress.nil? && progress.positive?

    " (#{progress}%)"
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

  def send_status_notification
    ExportJobsChannel.update_status_widget(self)
  end

  private

    def content_disposition(headers)
      Mechanize::HTTP::ContentDispositionParser.parse(headers[:content_disposition])
    end
end

# frozen_string_literal: true

# Model for metadata import jobs
#
# The "state" field records the current step in the processing of this job. The
# possible states are:
#
#   * :validate_pending - A "validate" request has been sent to Plastron, but
#                         no response has been received.
#
#   * :validate_success - A Plastron response was received indicating that the
#                         file is valid
#
#   * :validate_failed - A Plastron response was received indicating that the
#                         file was not valid
#
#   * :import_pending - An "import" request has been sent to Plastron, but
#                       no response has been received.
#
#   * :import_complete - All items in this import job have been successfully processed.
#
#   * :import_incomplete - Not all items in this import job have been successfully processed.
#
#   * :in_progress - Returned for any other status
#
#   * :validate_error - An error has occurred during validation, such as the
#                       STOMP client not being connected
#
#   * :import_error - An error has occurred during import, such as the
#                     STOMP client not being connected
class ImportJob < ApplicationRecord
  belongs_to :cas_user
  has_one_attached :metadata_file
  has_one_attached :binary_zip_file

  enum :state, {
    validate_pending: 1,
    validate_success: 2,
    validate_failed: 3,
    validate_error: 4,
    import_pending: 5,
    import_in_progress: 6,
    import_complete: 7,
    import_incomplete: 8,
    import_error: 9,
    validate_in_progress: 10
  }

  after_commit :send_status_notification

  validates :name, presence: true
  validates :collection, presence: true
  validate :attachment_validation
  validate :include_binaries_options

  # The relpath for "flat" structure collections
  FLAT_LAYOUT_RELPATH = '/pcdm'

  # If it has been more than IDLE_THRESHOLD since the last update time on this job,
  # and the job is in an active state, then consider it stalled.
  IDLE_THRESHOLD = 30.seconds

  def self.access_vocab
    @access_vocab ||= VocabularyService.get_vocabulary(VOCAB_CONFIG['access_vocab_identifier'])
  end

  # Rails 5.2 does not have attachment validation, so this is needed
  # until at least Rails 6 (see https://stackoverflow.com/questions/48158770/activestorage-file-attachment-validation)
  def attachment_validation
    errors.add(:metadata_file, :required) unless metadata_file.attached?
  end

  # Raises an error if both a "binary_zip_file" and a "remote server" field
  # is provided
  def include_binaries_options
    errors.add(:base, :multiple_include_binaries_options) if binary_zip_file.attached? && remote_server.present?
  end

  def update_progress(message) # rubocop:disable Metrics/AbcSize
    return if message.body.blank?

    validate_in_progress! if validate_pending?
    import_in_progress! if import_pending?

    count = message.body_json['count'] || {}
    total_count = count['total']

    # Total could be nil for non-seekable files
    unless total_count.nil? || total_count.zero?
      processed_count = count['created'] + count['updated'] + count['unchanged'] + count['errors']
      self.progress = (processed_count.to_f / total_count * 100).round
    end

    save!
  end

  def progress_text
    return '' unless !progress.nil? && progress.positive?

    " (#{progress}%)"
  end

  def update_status(message)
    if message.error?
      set_error_state
    else
      self.state = message.job_state
      if message.body.present?
        self.item_count = message.body_json.dig('count', 'total')
        self.binaries_count = message.body_json.dig('count', 'files')
      end
    end
    save!
  end

  # Heuristic method to determine if this job might be stalled
  def stalled?
    # only makes sense for jobs that are in an actively processing state
    return false unless active?

    (Time.zone.now - updated_at) > IDLE_THRESHOLD
  end

  def active?
    validate_pending? || import_pending? || validate_in_progress? || import_in_progress?
  end

  # Returns true if a binary zip file is attached, or remote server is
  # specified, false otherwise.
  def binaries?
    binaries_location.present?
  end

  # Returns the relpath of the collection (the collection with the
  # FCREPO_BASE_URL prefix removed). Will always start with a "/", and
  # returns FLAT_LAYOUT_RELPATH if the relpath starts with that value.
  def collection_relpath
    # Collection path could be either REPO_EXTERNAL_URL or FCREPO_BASE_URL,
    # so just strip both
    relpath = collection.sub(REPO_EXTERNAL_URL, '')
    relpath = relpath.sub(FCREPO_BASE_URL, '')

    # Ensure that relpath starts with a "/"
    relpath = "/#{relpath}" unless relpath.starts_with?('/')

    # Any path starting with "/pcdm" uses the flat layout, which always has
    # a relpath of '/pcdm'
    return FLAT_LAYOUT_RELPATH if relpath.starts_with?(FLAT_LAYOUT_RELPATH)

    relpath
  end

  # Returns ":flat" or ":hierarchical" based on the collections relpath
  def collection_structure
    relpath = collection_relpath

    return :flat if relpath.starts_with?(FLAT_LAYOUT_RELPATH)

    :hierarchical
  end

  def send_status_notification
    ImportJobsChannel.update_status_widget(self)
  end

  private

    # Set the appropriate error state depending on which phase of the import
    # this job is currently in.
    def set_error_state
      self.state = :validate_error if validate_pending? || validate_in_progress?
      self.state = :import_error if import_pending? || import_in_progress?
    end
end

# frozen_string_literal: true

# Model for metadata import jobs
#
# This model provides a simple workflow, tracking where the
# job is via the "stage" field. The "stage" field can have the
# following values:
#
#   * validate - The job is in the "validate" stage
#   * import - The job is in the "import" stage
#
# The normal workflow is for a job to move from "validate" to "import" when
# file validation is successful. If the file is not valid, the model stays
# in the "validate" stage.
#
# The "status" method generates the current status of the job from the
# Plastron response message. The possible statuses are:
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
#   * :import_success - A Plastron response was received indicating that the
#                       import succeeded.
#
#   * :import_failed - A Plastron response was received indicating that the
#                      import failed
#
#   * :in_progress - Returned for any other status
#
#   * :validate_error - An error has occurred during validation, such as the
#                       STOMP client not being connected
#
#   * :import_error - An error has occurred during import, such as the
#                     STOMP client not being connected
#   * :error - Generic error when stage is nil
class ImportJob < ApplicationRecord
  include PlastronStatus

  belongs_to :cas_user
  has_one_attached :metadata_file
  has_one_attached :binary_zip_file

  after_commit { ImportJobRelayJob.perform_later(self) }

  validates :name, presence: true
  validates :collection, presence: true
  validate :attachment_validation
  validate :include_binaries_options

  # The relpath for "flat" structure collections
  FLAT_LAYOUT_RELPATH = '/pcdm'

  def self.access_vocab
    @access_vocab ||= Vocabulary.find_by identifier: VOCAB_CONFIG['access_vocab_identifier']
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

  # Returns a symbol reflecting the current status
  def status # rubocop:disable Metrics/AbcSize
    if plastron_status_error?
      return stage ? "#{stage}_error".to_sym : :error
    end

    return "#{stage}_pending".to_sym if plastron_status_pending?

    return :in_progress unless plastron_status_done?

    response = ImportJobResponse.new(last_response_headers, last_response_body)
    return "#{stage}_success".to_sym if response.valid?

    "#{stage}_failed".to_sym
  end

  # Returns the next workflow action, based on the current status, or nil if
  # no workflow action is available.
  def workflow_action
    case status
    when :validate_success
      :import
    when :validate_failed, :validate_error
      :resubmit
    end
  end

  def update_progress(plastron_message) # rubocop:disable Metrics/AbcSize
    return if plastron_message.body.blank?

    count = plastron_message.body_json['count'] || {}
    total_count = count['total']

    # Total could be nil for non-seekable files
    return if total_count.nil? || total_count.zero?

    processed_count = count['created'] + count['updated'] + count['unchanged'] + count['errors']

    self.progress = (processed_count.to_f / total_count * 100).round
    save!
  end

  def update_status(plastron_message)
    if plastron_message.body.present?
      count = plastron_message.body_json['count'] || {}
      self.item_count = count['total']
      self.binaries_count = count['files']
    end
    self.plastron_status = plastron_message.headers['PlastronJobStatus']
    self.last_response_headers = plastron_message.headers.to_json
    self.last_response_body = plastron_message.body
    save!
  end

  def last_response
    ImportJobResponse.new(last_response_headers, last_response_body)
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
    relpath = collection.sub(FCREPO_BASE_URL, '')

    # Ensure that relpath starts with a "/"
    relpath = '/' + relpath unless relpath.starts_with?('/')

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
end

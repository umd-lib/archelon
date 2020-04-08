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
#   * :error - An error has occurred, such as the STOMP client not being
#              connected
class ImportJob < ApplicationRecord
  belongs_to :cas_user
  belongs_to :plastron_operation, dependent: :destroy
  has_one_attached :file_to_upload

  validates :name, presence: true
  validate :attachment_validation

  # Rails 5.2 does not have attachment validation, so this is needed
  # until at least Rails 6 (see https://stackoverflow.com/questions/48158770/activestorage-file-attachment-validation)
  def attachment_validation
    errors.add(:file_to_upload, :required) unless file_to_upload.attached?
  end

  # Returns a symbol reflecting the current status
  def status
    return "#{stage}_pending".to_sym if plastron_operation.pending?

    return :in_progress unless plastron_operation.done?

    response = ImportJobResponse.new(plastron_operation.response_message)
    return "#{stage}_success".to_sym if response.valid?

    "#{stage}_failed".to_sym
  end

  # Returns the next workflow action, based on the current status, or nil if
  # no workflow action is available.
  def workflow_action
    case status
    when :validate_success
      :import
    when :validate_failed
      :resubmit
    end
  end

  def update_progress(message)
    stats = message.body_json
    progress = (stats['count']['exported'].to_f / stats['count']['total'] * 100).round
    plastron_operation.progress = progress
    plastron_operation.save!
  end

  def update_status(message)
    plastron_operation.completed = Time.zone.now
    plastron_operation.status = message.headers['PlastronJobStatus']
    plastron_operation.response_message = message.body
    plastron_operation.save!
    save
  end
end

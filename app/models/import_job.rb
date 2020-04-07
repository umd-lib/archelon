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

  def status
    return "#{stage}_pending".to_sym if plastron_operation.pending?

    return nil unless plastron_operation.done?

    response = ImportJobResponse.new(plastron_operation.response_message)
    return "#{stage}_success".to_sym if response.valid?

    "#{stage}_failed".to_sym
  end

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

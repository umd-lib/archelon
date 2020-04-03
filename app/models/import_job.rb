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
end

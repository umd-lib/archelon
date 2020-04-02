class ImportJob < ApplicationRecord
  belongs_to :cas_user
  belongs_to :plastron_operation, dependent: :destroy
end

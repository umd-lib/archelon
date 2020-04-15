# frozen_string_literal: true

# Encapsulates the possible status responses from Plastron
module PlastronStatus
  extend ActiveSupport::Concern

  included do
    enum plastron_status: {
      plastron_status_pending: 'Pending',
      plastron_status_in_progress: 'In Progress',
      plastron_status_done: 'Done',
      plastron_status_failed: 'Failed',
      plastron_status_error: 'Error'
    }
  end
end

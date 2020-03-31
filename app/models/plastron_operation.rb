# frozen_string_literal: true

# Information about a particular Plastron operation.
class PlastronOperation < ApplicationRecord
  enum status: {
    pending: 'Pending',
    in_progress: 'In Progress',
    done: 'Done',
    failed: 'Failed',
    error: 'Error'
  }
end

# frozen_string_literal: true

# Model for metadata publish jobs
#
# The "state" field records the current step in the processing of this job. The
# possible states are:
#
#   * :publish_not_submitted - A "publish_job" has been created, but the job has not
#                             not been submitted to send a request to Plastron.
#
#   * :publish_pending - A "publish" request has been sent to Plastron, but
#                       no response has been received.
#
#   * :publish_complete - All items in this import job have been successfully processed.
#
#   * :publish_imcomplete - Not all items in this import job have been successfully processed.
#
#   * :publish_in_progress - Returned for any other status
#
#   * :publish_error - An error has occurred during publish, such as the
#                     STOMP client not being connected
class PublishJob < ApplicationRecord
  belongs_to :cas_user
  serialize :solr_ids, Array

  enum state: {
    publish_not_submitted: 1,
    publish_pending: 2,
    publish_in_progress: 3,
    publish_complete: 4,
    publish_incomplete: 5,
    publish_error: 6,
  }

  IDLE_THRESHOLD = 30.seconds

  # after_update_commit { PublishJobStatusUpdatedJob.perform_now(self) }

  def update_progress(message) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
    return if message.body.blank?

    publish_in_progress! if publish_pending?

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
        # self.item_count = message.body_json.dig('count', 'total')
        # self.binaries_count = message.body_json.dig('count', 'files')
      end
    end
    save!
  end

  def stalled?
    # only makes sense for jobs that are in an actively processing state
    return false unless active?

    (Time.zone.now - updated_at) > IDLE_THRESHOLD
  end

  def active?
    publish_pending? || publish_in_progress?
  end

  private

    # Set the appropriate error state depending on which phase of the publish
    # this job is currently in.
    def set_error_state
      self.state = :publish_error if publish_pending? || publish_in_progress?
    end
end

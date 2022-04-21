# frozen_string_literal: true

# Disables DownloadUrls that have expired
class DisableExpiredDownloadUrlsJob < ApplicationJob
  queue_as :default

  # Disables all enabled DownloadUrls with an expiration date less than or equal
  # to the given time.
  def perform(current_time)
    Rails.logger.info "Running DisableExpiredDownloadUrlsCronJob at #{current_time}"

    urls_to_expire = DownloadUrl.where(enabled: true).where('expires_at <= ?', current_time)
    if urls_to_expire.any?
      Rails.logger.info "Disabling #{urls_to_expire.size} expired URLs"
      urls_to_expire.update_all(enabled: false) # rubocop:disable Rails/SkipsModelValidations
    else
      Rails.logger.info('No URLs have expired.')
    end
  end
end

# frozen_string_literal: true

# Disables DownloadUrls that have expired
class DownloadUrlExpirationJob < ApplicationJob
  queue_as :expire_download_urls # Note: ignored by Resque

  # Disables all enabled DownloadUrls with an expiration date less than or equal
  # to the given time.
  def perform(current_time = Time.current)
    Rails.logger.debug "Running with current_time=#{current_time}"
    urls_to_expire = DownloadUrl.where(enabled: true).where('expires_at <= ?', current_time)
    if urls_to_expire.any?
      Rails.logger.debug "Disabling #{urls_to_expire.size} expired URLs"
      urls_to_expire.update_all(enabled: false) # rubocop:disable Rails/SkipsModelValidations
    else
      Rails.logger.debug('No URLs have expired.')
    end
  end
end

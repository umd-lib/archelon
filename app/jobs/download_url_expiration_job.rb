# frozen_string_literal: true

# Disables DownloadUrls that have expired
class DownloadUrlExpirationJob < ApplicationJob
  queue_as :default

  # Disables all enabled DownloadUrls with an expiration date less than or equal
  # to the given time.
  def perform(current_time = Time.current)
    urls_to_expire = DownloadUrl.where(enabled: true).where('expires_at <= ?', current_time)
    urls_to_expire.update_all(enabled: false) # rubocop:disable Rails/SkipsModelValidations
  end
end

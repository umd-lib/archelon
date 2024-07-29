# frozen_string_literal: true

# A DownloadUrl for retrieving Fedora document
class DownloadUrl < ApplicationRecord
  include Tokenable

  validates :notes, presence: true

  def expired?
    expires_at < Time.zone.now
  end

  # Return a String representing the one-time use URL to retrieve the
  # associated Fedora document.
  def retrieve_url
    ENV['RETRIEVE_BASE_URL'] + token
  end

  # UMD Blacklight 8 Fix
  def self.ransackable_associations(auth_object = nil)
    []
  end

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "enabled_eq", "creator_eq"]
  end
  # End UMD Blacklight 8 Fix
end

# A DownloadUrl for retrieving Fedora document
class DownloadUrl < ActiveRecord::Base
  include Tokenable

  validates :notes, presence: true

  def expired?
    expires_at < Time.zone.now
  end
end

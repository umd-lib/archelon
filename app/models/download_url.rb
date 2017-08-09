# A DownloadUrl for retrieving Fedora document
class DownloadUrl < ActiveRecord::Base
  include Tokenable

  validates :notes, presence: true

  def expired?
    expires_at < Time.now
  end
end

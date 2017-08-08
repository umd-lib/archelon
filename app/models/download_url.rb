class DownloadUrl < ActiveRecord::Base
  include Tokenable

  validates :notes, presence: true
end

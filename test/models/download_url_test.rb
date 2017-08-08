require 'test_helper'

class DownloadUrlTest < ActiveSupport::TestCase
  test 'different instances have different tokens' do
    download_url1 = DownloadUrl.new
    download_url1.save!
    download_url2 = DownloadUrl.new
    download_url2.save!

    assert_not_equal download_url1.token, download_url2.token
  end
end

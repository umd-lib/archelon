require 'test_helper'

class DownloadUrlTest < ActiveSupport::TestCase
  test 'different instances have different tokens' do
    download_url1 = DownloadUrl.new
    download_url1.notes = 'download_url1'
    download_url1.save!

    download_url2 = DownloadUrl.new
    download_url2.notes = 'download_url2'
    download_url2.save!

    assert_not_equal download_url1.token, download_url2.token
  end

  test 'note field must be non-blank' do
    download_url = download_urls(:one)
    assert download_url.valid?

    download_url.notes = nil
    refute download_url.valid?

    download_url.notes = ''
    refute download_url.valid?

    download_url.notes = 'abc'
    assert download_url.valid?
  end
end

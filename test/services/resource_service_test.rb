# frozen_string_literal: true

require 'test_helper'

class ResourceServiceTest < ActionView::TestCase
  def setup
    @resource_service = ResourceService.new(endpoint: 'http://fcrepo.example.com/fcrepo/rest')
  end

  def test_fedora_resource_title # rubocop:disable Metrics/MethodLength
    @id = 'test_id'
    @resource = create_title_resource(@id, nil)
    display_title = @resource_service.display_title(@resource, @id)
    assert_nil display_title

    @resource = create_title_resource(@id, [{ '@value' => 'None Title' }])
    display_title = @resource_service.display_title(@resource, @id)
    assert_equal('None Title', display_title)

    @resource = create_title_resource(
      @id,
      [
        { '@value' => 'ja Title', '@language' => 'ja' },
        { '@value' => 'ja-latn Title', '@language' => 'ja-latn' }
      ]
    )
    display_title = @resource_service.display_title(@resource, @id)
    assert_equal('ja-latn Title, ja Title', display_title)

    @resource = create_title_resource(
      @id,
      [
        { '@value' => 'en Title', '@language' => 'en' },
        { '@value' => 'ja Title', '@language' => 'ja' },
        { '@value' => 'ja-latn Title', '@language' => 'ja-latn' },
        { '@value' => 'None Title' }
      ]
    )
    display_title = @resource_service.display_title(@resource, @id)
    assert_equal('None Title, en Title, ja-latn Title, ja Title', display_title)
  end

  def test_sort_titles_by_language
    resource_titles = [
      { '@value' => 'ja Title', '@language' => 'ja' },
      { '@value' => 'ja-latn Title', '@language' => 'ja-latn' },
      { '@value' => 'en Title', '@language' => 'en' },
      { '@value' => 'None Title' }
    ]

    sorted_titles = @resource_service.sort_titles_by_language(resource_titles)
    assert_equal(['None Title', 'en Title', 'ja-latn Title', 'ja Title'], sorted_titles)
  end

  def test_resource_service_with_origin
    service = ResourceService.new(
      endpoint: 'https://fcrepo.example.com/fcrepo/rest',
      origin: 'http://fcrepo-webapp:8080/fcrepo/rest'
    )
    assert_equal({ 'X-Forwarded-Proto': 'https', 'X-Forwarded-Host': 'fcrepo.example.com' }, service.forwarding_headers)
    assert_equal('http://fcrepo-webapp:8080/fcrepo/rest/foo:123', service.request_url('https://fcrepo.example.com/fcrepo/rest/foo:123'))
  end

  # Test helper methods
  def create_title_resource(id, titles)
    return { items: { id => {} } } unless titles

    { items: { id => { 'http://purl.org/dc/terms/title' => titles } } }
  end
end

# frozen_string_literal: true

require 'test_helper'

class ResourceServiceTest < ActionView::TestCase
  def setup
  end

  def test_fedora_resource_title # rubocop:disable Metrics/MethodLength
    @id = 'test_id'
    @resource = create_title_resource(@id, nil)
    display_title = ResourceService.display_title(@resource, @id)
    assert_nil display_title

    @resource = create_title_resource(@id, [{ '@value' => 'None Title' }])
    display_title = ResourceService.display_title(@resource, @id)
    assert_equal('None Title', display_title)

    @resource = create_title_resource(
      @id,
      [
        { '@value' => 'ja Title', '@language' => 'ja' },
        { '@value' => 'ja-latn Title', '@language' => 'ja-latn' }
      ]
    )
    display_title = ResourceService.display_title(@resource, @id)
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
    display_title = ResourceService.display_title(@resource, @id)
    assert_equal('None Title, en Title, ja-latn Title, ja Title', display_title)
  end

  def test_sort_titles_by_language
    resource_titles = [
      { '@value' => 'ja Title', '@language' => 'ja' },
      { '@value' => 'ja-latn Title', '@language' => 'ja-latn' },
      { '@value' => 'en Title', '@language' => 'en' },
      { '@value' => 'None Title' }
    ]

    sorted_titles = ResourceService.sort_titles_by_language(resource_titles)
    assert_equal(['None Title', 'en Title', 'ja-latn Title', 'ja Title'], sorted_titles)
  end

  # Test helper methods
  def create_title_resource(id, titles)
    return { items: { id => {} } } unless titles

    { items: { id => { 'http://purl.org/dc/terms/title' => titles } } }
  end
end

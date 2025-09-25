# frozen_string_literal: true

# Represents a single document returned from Solr
class SolrDocument # rubocop:disable Metrics/ClassLength
  include Blacklight::Solr::Document
  include ActionView::Helpers::TagHelper
  include Rails.application.routes.url_helpers

  # self.unique_key = 'id'

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  def creator_language_badge
    return unless has? 'object__creator'

    Array(fetch('object__creator')).map do |creator|
      tagged_names = creator[:agent__label__display].map { |name| format_with_language_tag(name) }
      safe_join(tagged_names, ' | ')
    end
  end

  def audience_language_badge
    return unless has? 'object__audience'

    Array(fetch('object__audience')).map do |audience|
      tagged_names = audience[:agent__label__display].map { |name| format_with_language_tag(name) }
      safe_join(tagged_names, ' | ')
    end
  end

  def title_language_badge
    return unless has? 'object__title__display'

    Array(fetch('object__title__display')).map { |title| format_with_language_tag(title) }
  end

  def archival_collection_links
    handle_link = vocab_term_with_same_as(:object__archival_collection,
                                          anchor_label: 'View Collection in Archival Collection Database')

    archelon_search_link = ActionController::Base.helpers.link_to('View Collection in Archelon',
                                                                  search_catalog_path('f[archival_collection__facet][]' => fetch('object__archival_collection__label__txt'))) # rubocop:disable Layout/LineLength

    [handle_link, archelon_search_link]
  end

  def format_anchor
    vocab_term_with_same_as :object__format
  end

  def handle_anchor
    return unless has? 'handle__id'

    add_anchor_tag(fetch('handle_proxied__uri'), fetch('handle__id'))
  end

  def members_anchor
    return unless has? 'page_uri_sequence__uris'

    labels = fetch('page_label_sequence__txts')
    uris = fetch('page_uri_sequence__uris')

    paired_uris = uris.zip(labels)

    paired_uris.map do |uri, label|
      add_anchor_tag(solr_document_path(uri), label)
    end
  end

  def rights_anchor
    vocab_term_with_same_as :object__rights
  end

  def object_type_anchor
    vocab_term_with_uri :object__object_type, label_suffix: '__label__txt_en'
  end

  def terms_of_use
    return unless has? 'object__terms_of_use__value__txt'

    terms_text = fetch('object__terms_of_use__value__txt')
    return terms_text unless has? 'object__terms_of_use__label__txt'

    "#{fetch('object__terms_of_use__label__txt')}: #{terms_text}"
  end

  # Concatenates titles for display, stripping out any language tags
  def display_titles
    strip_language_tags(:object__title__display).join(' | ')
  end

  # Get the extracted text snippets from the highlighting results and strips out
  # the page and bounding box tags
  def extracted_text
    text_values = response.dig('highlighting', id, 'extracted_text__dps_txt') || []
    text_values.map { |value| value.gsub(/\|n=\d+&xywh=\d+,\d+,\d+,\d+/, '') }
  end

  private

    def extract_language_tags(field_name)
      return [] unless has? field_name

      fetch(field_name, []).map { |value| parse_language_tagged_value(value) }
    end

    def parse_language_tagged_value(value)
      if value =~ /^\[@(.*?)\](.*)/
        { value: ::Regexp.last_match(2), lang: ::Regexp.last_match(1) }
      else
        { value: value, lang: nil }
      end
    end

    def strip_language_tags(field_name)
      extract_language_tags(field_name).pluck(:value)
    end

    def format_with_language_tag(value)
      parsed_value = parse_language_tagged_value(value)
      return parsed_value[:value] if parsed_value[:lang].nil?

      safe_join([parsed_value[:value], tag.span(parsed_value[:lang], class: %w[badge text-bg-secondary])], "\xa0")
    end

    def add_anchor_tag(uri, label)
      tag.a(label, href: uri)
    end

    def vocab_term_with_uri(base_field, label_suffix: '__label__txt', anchor_label: nil)
      return unless has? "#{base_field}__uri"

      uri = fetch("#{base_field}__uri")
      label = fetch("#{base_field}#{label_suffix}", uri)

      safe_join([label, tag.a(anchor_label || uri, href: uri)], ' → ')
    end

    def vocab_term_with_same_as(base_field, label_suffix: '__label__txt', same_as_suffix: '__same_as__uris',
                                anchor_label: nil)
      return unless has? "#{base_field}__uri"

      uri = fetch("#{base_field}__uri")
      label = fetch("#{base_field}#{label_suffix}", uri)
      same_as_uri = fetch("#{base_field}#{same_as_suffix}", []).first
      return label if same_as_uri.nil?

      safe_join([label, tag.a(anchor_label || same_as_uri, href: same_as_uri)], ' → ')
    end
end

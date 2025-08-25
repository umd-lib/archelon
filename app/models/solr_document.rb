# frozen_string_literal: true

# Represents a single document returned from Solr
class SolrDocument
  include Blacklight::Solr::Document
  include ActionView::Helpers::TagHelper

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

  def archival_collection_anchor
    vocab_term_with_same_as :object__archival_collection
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
      add_anchor_tag(uri, label)
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
    return '' unless has? 'object__title__display'

    titles = fetch(:object__title__display, []).map do |title|
      title.starts_with?('[@') ? title.split(']')[1] : title
    end
    titles.join(' | ')
  end

  private

    def format_with_language_tag(value)
      if value.starts_with? '[@'
        language_tag = value.split(']')[0][2...]
        value = value.split(']')[1]
        safe_join([value, tag.span(language_tag, class: %w[badge text-bg-secondary])], "\xa0")
      else
        value
      end
    end

    def add_anchor_tag(uri, label)
      tag.a(label, href: uri)
    end

    def vocab_term_with_uri(base_field, label_suffix: '__label__txt')
      return unless has? "#{base_field}__uri"

      uri = fetch("#{base_field}__uri")
      label = fetch("#{base_field}#{label_suffix}", uri)

      safe_join([label, tag.a(uri, href: uri)], ' → ')
    end

    def vocab_term_with_same_as(base_field, label_suffix: '__label__txt', same_as_suffix: '__same_as__uris')
      return unless has? "#{base_field}__uri"

      uri = fetch("#{base_field}__uri")
      label = fetch("#{base_field}#{label_suffix}", uri)
      same_as_uri = fetch("#{base_field}#{same_as_suffix}", []).first
      return label if same_as_uri.nil?

      safe_join([label, tag.a(same_as_uri, href: same_as_uri)], ' → ')
    end
end

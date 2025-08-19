# frozen_string_literal: true

# Represents a single document returned from Solr
class SolrDocument
  include Blacklight::Solr::Document

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
      creator[:agent__label__display].map { |name| format_with_language_tag(name) }.join(' | ').html_safe
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

  def member_of_anchor
    return unless has? 'admin_set__facet'
    return fetch('admin_set__facet')
  end

  def rights_anchor
    vocab_term_with_same_as :object__rights
  end

  def object_type_anchor
    vocab_term_with_uri :object__object_type, label_suffix: '__label__txt_en'
  end

  private

    def format_with_language_tag(value)
      if value.starts_with? '[@'
        language_tag = value.split(']')[0][2...]
        value = value.split(']')[1]
        value.html_safe + " <span class=\"badge text-bg-secondary\">#{language_tag}</span>".html_safe
      else
        value.html_safe
      end
    end

    def add_anchor_tag(uri, label)
      "<a href=#{uri}> #{label} </a>".html_safe
    end

    def vocab_term_with_uri(base_field, label_suffix: '__label__txt')
      return unless has? "#{base_field}__uri"

      uri = fetch("#{base_field}__uri")
      label = fetch("#{base_field}#{label_suffix}") || uri

      "#{label} → <a href=#{uri}>#{uri}</a>".html_safe
    end

    def vocab_term_with_same_as(base_field, label_suffix: '__label__txt', same_as_suffix: '__same_as__uris')
      return unless has? "#{base_field}__uri"

      uri = fetch("#{base_field}__uri")
      label = fetch("#{base_field}#{label_suffix}") || uri
      same_as_uri = fetch("#{base_field}#{same_as_suffix}").first
      return label if same_as_uri.nil?

      "#{label} → <a href=#{same_as_uri}>#{same_as_uri}</a>".html_safe
    end
end

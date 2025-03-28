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

  def add_language_badge
    return unless has? 'item__title__display'

    Array(fetch('item__title__display')).map do |title|
      if title.starts_with? '['
        language = title.split(']')[0][2...]
        title = title.split(']')[1]

        title.html_safe + " <span class=\"badge text-bg-secondary\">#{language}</span>".html_safe
      else
        title.html_safe
      end
    end
  end

  def archival_collection_anchor
    return unless has? 'item__archival_collection__uri'
    add_anchor_tag(fetch('item__archival_collection__uri'), fetch('item__archival_collection__label__txt'))
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
    return unless has? 'item__member_of__uri'
    add_anchor_tag(fetch('item__member_of__uri'), fetch('item__member_of__uri'))
  end

  def rights_anchor
    return unless has? 'item__rights__uri'
    add_anchor_tag(fetch('item__rights__uri'), fetch('item__rights__label__txt'))
  end

  def terms_anchor
    return unless has? 'item__terms_of_use__uri'
    add_anchor_tag(fetch('item__terms_of_use__uri'), fetch('item__terms_of_use__label__txt'))
  end

  def object_type_anchor
    return unless has? 'item__object_type__uri'
    add_anchor_tag(fetch('item__object_type__uri'), fetch('item__object_type__uri'))
  end

  private

    def add_anchor_tag(uri, label)
      "<a href=#{uri}> #{label} </a>".html_safe
    end
end

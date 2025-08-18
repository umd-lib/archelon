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
      language_tags = creator[:agent__label__display].map do |name|
        if name.starts_with? '[@'
          language_tag = name.split(']')[0][2...]
          actual_name = name.split(']')[1]
          actual_name.html_safe + " <span class=\"badge text-bg-secondary\">#{language_tag}</span>".html_safe
        else
          name.html_safe
        end
      end
      language_tags.join(' | ').html_safe
    end
  end

  def title_language_badge
    return unless has? 'object__title__display'

    Array(fetch('object__title__display')).map do |title|
      if title.starts_with? '[@'
        language_tag = title.split(']')[0][2...]
        title = title.split(']')[1]

        title.html_safe + " <span class=\"badge text-bg-secondary\">#{language_tag}</span>".html_safe
      else
        title.html_safe
      end
    end
  end

  def archival_collection_anchor
    return unless has? 'object__archival_collection__uri'
    add_anchor_tag(fetch('object__archival_collection__uri'), fetch('object__archival_collection__label__txt'))
  end

  def format_anchor
    return unless has? 'object__format__uri'
    add_anchor_tag(fetch('object__format__uri'), fetch('object__format__label__txt'))
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
    return unless has? 'object__rights__uri'
    add_anchor_tag(fetch('object__rights__uri'), fetch('object__rights__label__txt'))
  end

  def terms_anchor
    return unless has? 'object__terms_of_use__uri'
    add_anchor_tag(fetch('object__terms_of_use__uri'), fetch('object__terms_of_use__label__txt'))
  end

  def object_type_anchor
    return unless has? 'object__object_type__uri'
    add_anchor_tag(fetch('object__object_type__uri'), fetch('object__object_type__uri'))
  end

  private

    def add_anchor_tag(uri, label)
      "<a href=#{uri}> #{label} </a>".html_safe
    end
end

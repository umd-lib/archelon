# frozen_string_literal: true

require 'link_header'

# Utilities to retrieve resources from the repository
class ResourceService
  def self.description_uri(uri)
    response = HTTP.head(uri, ssl_context: SSL_CONTEXT)
    if response.headers.include? 'Link'
      links = LinkHeader.parse(response['Link'].join(','))
      links.find_link(%w[rel describedby])&.href || uri
    else
      uri
    end
  end

  def self.resources(uri)
    response = HTTP[accept: 'application/ld+json'].get(description_uri(uri), ssl_context: SSL_CONTEXT)
    input = JSON.parse(response.body.to_s)
    JSON::LD::API.expand(input)
  end

  def self.resource_with_model(id)
    # create a hash of resources by their URIs
    items = Hash[resources(id).map do |resource|
      uri = resource.delete('@id')
      [uri, resource]
    end]

    name = content_model_name(items[id]['@type'])
    {
      items: items,
      content_model_name: name,
      content_model: CONTENT_MODELS[name]
    }
  end

  CONTENT_MODEL_MAP = [
    [:Issue, ->(types) { types.include? 'http://purl.org/ontology/bibo/Issue' }],
    [:Letter, ->(types) { types.include? 'http://purl.org/ontology/bibo/Letter' }],
    [:Poster, ->(types) { types.include? 'http://purl.org/ontology/bibo/Image' }],
    [:Page, ->(types) { types.include? 'http://purl.org/spar/fabio/Page' }],
    [:Page, ->(types) { types.include? 'http://chroniclingamerica.loc.gov/terms/Page' }],
    [:Item, ->(types) { types.include? 'http://pcdm.org/models#Object' }],
    [:Item, ->(types) { types.include? 'http://pcdm.org/models#File' }]
  ].freeze

  def self.content_model_name(types)
    CONTENT_MODEL_MAP.filter { |pair| pair[1].call(types) }.first[0]
  end

  # Returns the display title for the Fedora resource, or nil
  def self.display_title(resource, id)
    return unless resource && id

    resource_titles = resource.dig(:items, id, 'http://purl.org/dc/terms/title')
    return if resource_titles.blank?

    sorted_titles = sort_titles_by_language(resource_titles)
    return sorted_titles.join(', ') if sorted_titles
  end

  # Sorts resource titles by language to ensure consistent ordering
  def self.sort_titles_by_language(resource_titles) # rubocop:disable Metrics/MethodLength
    languages_map = {}
    resource_titles.each do |title|
      language = title['@language'] || 'None'
      language_list = languages_map.fetch(language, [])
      languages_map[language] = language_list.push(title['@value'])
    end
    ordered_languages = %w[None en ja-latn ja]
    sorted_titles = []
    ordered_languages.each do |language|
      sorted_titles.push(*languages_map.fetch(language, []))
    end
    sorted_titles
  end
end

# frozen_string_literal: true

require 'link_header'

# Utilities to retrieve resources from the repository
class ResourceService
  def self.fcrepo_http_client
    headers = {}
    headers['Authorization'] = "Bearer #{FCREPO_AUTH_TOKEN}" if FCREPO_AUTH_TOKEN
    HTTP::Client.new(headers: headers, ssl_context: SSL_CONTEXT)
  end

  def self.description_uri(uri)
    response = fcrepo_http_client.head(uri)
    if response.headers.include? 'Link'
      links = LinkHeader.parse(response['Link'].join(','))
      links.find_link(%w[rel describedby])&.href || uri
    else
      uri
    end
  end

  def self.get(uri, **opts)
    fcrepo_http_client.get(uri, opts)
  end

  def self.resources(uri)
    response = get(description_uri(uri), headers: { accept: 'application/ld+json' })
    # This is a bit of a kludge to get around problems with building a string from the
    # response body content when the "frozen_string_literal: true" pragma is in effect.
    # Start with an unfrozen empty string (created using the unary '+' operator), then
    # accumulate the body chunks.
    body = +''
    response.body.each { |chunk| body << chunk }
    input = JSON.parse(body)
    JSON::LD::API.expand(input)
  end

  def self.resource_with_model(id)
    # create a hash of resources by their URIs
    items = Hash[resources(id).map do |resource|
      uri = resource.delete('@id')
      [uri, resource]
    end]

    # default to the Item content model
    name = content_model_name(items[id]['@type']) || :Item
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
    CONTENT_MODEL_MAP.find { |pair| pair[1].call(types) }&.first
  end

  # Returns the display title for the Fedora resource, or nil
  def self.display_title(resource, id)
    return unless resource && id

    resource_titles = resource.dig(:items, id, 'http://purl.org/dc/terms/title')
    return if resource_titles.blank?

    sorted_titles = sort_titles_by_language(resource_titles)
    sorted_titles.join(', ') if sorted_titles
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

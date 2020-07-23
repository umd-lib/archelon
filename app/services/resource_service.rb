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
end

# frozen_string_literal: true

require 'link_header'

# Utilities to retrieve resources from the repository
class ResourceService
  def initialize(endpoint:, origin: nil, auth_token: nil)
    @endpoint = URI(endpoint)
    @origin = origin ? URI(origin) : nil
    @auth_token = auth_token
  end

  def forwarding_headers
    return {} unless @origin

    {
      'X-Forwarded-Proto': @endpoint.scheme,
      # fcrepo expects the hostname and port in the X-Forwarded-Host header
      # Ruby's URI#authority gives us both with intelligent defaulting if the
      # port is the default for the scheme
      'X-Forwarded-Host': @endpoint.authority
    }
  end

  def authorization_headers
    @auth_token ? { Authorization: "Bearer #{@auth_token}" } : {}
  end

  def request_headers
    { **forwarding_headers, **authorization_headers }
  end

  def client
    Rails.logger.debug { "Request headers: #{request_headers}" }
    @client ||= HTTP::Client.new(headers: request_headers, ssl_context: SSL_CONTEXT)
  end

  def request_url(uri)
    raise "invalid URI for this repository: #{uri}" unless uri.start_with? @endpoint.to_s

    @origin ? uri.sub(@endpoint, @origin) : uri
  end

  def description_uri(uri)
    Rails.logger.debug { "Request URI: #{uri}" }
    Rails.logger.debug { "Request URL: #{request_url(uri)}" }
    response = client.head(request_url(uri))
    if response.headers.include? 'Link'
      links = LinkHeader.parse(response['Link'].join(','))
      links.find_link(%w[rel describedby])&.href || uri
    else
      uri
    end
  end

  def get(uri, **opts)
    client.get(uri, opts)
  end

  def resources(uri)
    response = get(request_url(description_uri(uri)), headers: { accept: 'application/ld+json' })
    # This is a bit of a kludge to get around problems with building a string from the
    # response body content when the "frozen_string_literal: true" pragma is in effect.
    # Start with an unfrozen empty string (created using the unary '+' operator), then
    # accumulate the body chunks.
    body = +''
    response.body.each { |chunk| body << chunk }
    input = JSON.parse(body)
    JSON::LD::API.expand(input)
  end

  def resource_with_model(uri)
    # create a hash of resources by their URIs
    items = resources(uri).to_h do |resource|
      uri = resource.delete('@id')
      [uri, resource]
    end

    name = content_model_name(items[uri]['@type'] || [])
    {
      items: items,
      content_model_name: name,
      content_model: CONTENT_MODELS[name]
    }
  end

  def content_model_name(types)
    return :Issue if types.include? 'http://vocab.lib.umd.edu/model#Newspaper'

    # default to the Item content model
    :Item
  end

  # Returns the display title for the Fedora resource, or nil
  def display_title(resource, id)
    return unless resource && id

    resource_titles = resource.dig(:items, id, 'http://purl.org/dc/terms/title')
    return if resource_titles.blank?

    sorted_titles = sort_titles_by_language(resource_titles)
    sorted_titles&.join(', ')
  end

  # Sorts resource titles by language to ensure consistent ordering
  def sort_titles_by_language(resource_titles) # rubocop:disable Metrics/MethodLength
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

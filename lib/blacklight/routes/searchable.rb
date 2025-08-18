# frozen_string_literal: true

module Blacklight
  module Routes
    # Archelon is unusual in that the “id” parameters for individual item pages
    # contains the URL of the “fcrepo” server. This URL contains “.”
    # (period) characters that are confusing to the stock Blacklight route
    # handlers
    #
    # This files is copied from the “lib/blacklight/routes/searchable.rb” file
    # from Blacklight 8.3.0, and modified to add the constraints: { id: /.*/ }.
    #
    # Also add constraints: { id: /.*/ } to the affected routed in
    # “config/routes.rb”.
    class Searchable
      def initialize(defaults = {})
        @defaults = defaults
      end

      def call(mapper, _options = {})
        mapper.match '/', action: 'index', as: 'search', via: %i[get post]
        mapper.get '/advanced', action: 'advanced_search', as: 'advanced_search'
        mapper.get '/page_links', action: 'page_links', as: 'page_links'

        mapper.post ':id/track', action: 'track', as: 'track', constraints: { id: /.*/ }
        mapper.get ':id/raw', action: 'raw', as: 'raw', defaults: { format: 'json' }

        mapper.get 'opensearch'
        mapper.get 'suggest', as: 'suggest_index'
        mapper.get 'facet/:id', action: 'facet', as: 'facet'
      end
    end
  end
end

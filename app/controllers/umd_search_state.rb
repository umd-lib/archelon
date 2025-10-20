# frozen_string_literal: true

# Override BlackLight::SearchState to customize search parameters
#
# To use in a controller including Blacklight::Catalog, simply add the following
# line:
#
#   self.search_state_class = UmdSearchState
#
class UmdSearchState < Blacklight::SearchState
  def initialize(params, blacklight_config, controller = nil)
    super
  end

  def params
    rewrite_query_for_http_identifier_search
    @params
  end

  # For "identifier" searches, modifies the query to enable Solr to
  # find both "http" and "https" versions of the identifier, no matter
  # which one the user specified.
  def rewrite_query_for_http_identifier_search
    return unless @params['search_field'] == 'identifier'

    q_param = @params['q']

    q_param.sub!(/^https:/, 'http*:')
    q_param.sub!(/^http:/, 'http*:')
    @params['q'] = q_param
  end
end

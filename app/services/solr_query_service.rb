# frozen_string_literal: true

# Base class for services implementing specific Solr queries
class SolrQueryService
  include Blacklight::Configurable

  blacklight_config.http_method = :post

  def self.match_any(field, values)
    values.map { |value| "#{field}:\"#{value}\"" }.join(' OR ')
  end
end

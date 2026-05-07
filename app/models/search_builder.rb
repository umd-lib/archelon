# frozen_string_literal: true

# Customized SearchBuilder
class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior

  self.default_processor_chain += %i[build_date_range_query]

  def build_date_range_query(solr_parameters) # rubocop:disable Metrics/AbcSize
    return unless blacklight_params[:begin_date].present? || blacklight_params[:end_date].present?

    %i[fq bq bf].each { |key| solr_parameters[key] ||= [] }
    field = blacklight_config.date_fields[:range].to_s
    date_range_query = DateRangeQuery.new(*blacklight_params.slice(:begin_date, :end_date).values)
    solr_parameters[:fq] << date_range_query.fq(field)
    # boost dates/date ranges that fall completely within the queried range
    solr_parameters[:bq] << date_range_query.fq(field, :Within)
    # also boost dates/date ranges...
    # ...with higher precision
    solr_parameters[:bf] << blacklight_config.date_fields[:precision].to_s
    # ...with a smaller range
    solr_parameters[:bf] << "div(1,#{blacklight_config.date_fields[:range_size]})"
    # ...without qualifiers
    blacklight_config.date_qualifier_fields.each { |f| solr_parameters[:bf] << "not(#{f})" }
  end
end

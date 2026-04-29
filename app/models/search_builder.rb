# frozen_string_literal: true

# Customized SearchBuilder
class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior

  self.default_processor_chain += %i[build_date_range_query]

  def build_date_range_query(solr_parameters)
    return unless blacklight_params[:begin_date].present? || blacklight_params[:end_date].present?

    query = build_date_query(*blacklight_params.slice(:begin_date, :end_date).values)
    solr_parameters[:fq] += ["object__date__dt:#{query}"]
  end

  private

    def build_date_query(begin_date, end_date)
      if begin_date.present? && end_date.present?
        "[#{begin_date} TO #{end_date}]"
      elsif begin_date.present?
        begin_date
      elsif end_date.present?
        "[* TO #{end_date}]"
      end
    end
end

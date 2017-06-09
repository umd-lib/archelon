# frozen_string_literal: true
class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  self.default_processor_chain += [:allow_annotations_if_query_non_empty]

  def allow_annotations_if_query_non_empty(solr_parameters)
    solr_parameters[:fq] = ['is_pcdm:true OR rdf_type:oa\:Annotation'] if solr_parameters[:q].present?
  end
end

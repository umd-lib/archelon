# frozen_string_literal: true

# Customized SearchBuilder
class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  self.default_processor_chain += %i[allow_annotations_if_query_non_empty exportable_only]

  def allow_annotations_if_query_non_empty(solr_parameters)
    return if solr_parameters[:q].blank?

    solr_parameters[:fq] << 'rdf_type:oa\:Annotation'
  end

  def exportable_only(solr_parameters)
    return unless blacklight_params[:exportable_only]

    solr_parameters[:fq] <<
      '!content_model_name__str:Page AND !content_model_name__str:Article AND !content_model_name__str:Collection AND !rdf_type:fedora\:Binary'
  end
end

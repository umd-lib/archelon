# frozen_string_literal: true

class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior

  ##
  # @example Adding a new step to the processor chain
  #   self.default_processor_chain += [:add_custom_data_to_query]
  #
  #   def add_custom_data_to_query(solr_parameters)
  #     solr_parameters[:custom] = blacklight_params[:user_value]
  #   end

  # UMD Customization
  self.default_processor_chain += %i[allow_annotations_if_query_non_empty exportable_only]

  def allow_annotations_if_query_non_empty(solr_parameters)
    return if solr_parameters[:q].blank?

    solr_parameters[:fq].delete('is_pcdm:true') if solr_parameters[:fq].include? 'is_pcdm:true'
    solr_parameters[:fq] << 'is_pcdm:true OR rdf_type:oa\:Annotation'
  end

  def exportable_only(solr_parameters)
    return unless blacklight_params[:exportable_only]

    solr_parameters[:fq] <<
      '!component:Page AND !component:Article AND !component:Collection AND !rdf_type:fedora\:Binary'
  end
  # End UMD Customization
end

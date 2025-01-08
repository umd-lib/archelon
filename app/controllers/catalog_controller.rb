# frozen_string_literal: true

class CatalogController < ApplicationController # rubocop:disable Metrics/ClassLength
  include Blacklight::Catalog
  before_action :make_current_query_accessible, only: %i[show index]

  rescue_from Blacklight::Exceptions::ECONNREFUSED, with: :goto_about_page
  rescue_from Blacklight::Exceptions::InvalidRequest, with: :goto_about_page

  configure_blacklight do |config| # rubocop:disable Metrics/BlockLength
    ## Class for sending and receiving requests from a search index
    # config.repository_class = Blacklight::Solr::Repository
    #
    ## Class for converting Blacklight's url parameters to into request parameters for the search index
    # config.search_builder_class = ::SearchBuilder
    #
    ## Model that maps search index responses to the blacklight response model
    # config.response_model = Blacklight::Solr::Response

    ## Default parameters to send to solr for all search-like requests. See also SearchBuilder#processed_parameters
    # The fq parameter is conditionally overriden in app/models/search_builder.rb
    config.default_solr_params = {
      rows: 10,
    }

    config.fetch_many_document_params = {
      fl: '*'
    }

    # solr path which will be added to solr base url before the other solr params.
    config.solr_path = 'search'
    config.document_solr_path = 'document'

    # items to show per page, each number in the array represent another option to choose from.
    # config.per_page = [10,20,50,100]

    ## Default parameters to send on single-document requests to Solr. These settings are the Blackligt defaults (see
    ## SearchHelper#solr_doc_params) or parameters included in the Blacklight-jetty document requestHandler.
    #
    # config.default_document_solr_params = {
    #  qt: 'document',
    #  ## These are hard-coded in the blacklight 'document' requestHandler
    #  # fl: '*',
    #  # rows: 1,
    #  # q: '{!term f=id v=$id}'
    # }

    # Remove default right-side rendering of blacklight bookmark select checkbox
    config.index.document_actions.delete(:bookmark)

    # solr field configuration for search results/index views
    config.index.title_field = 'item__title__txt'

    # solr field configuration for document/show views
    config.show.title_field = 'item__title__txt'
    # config.show.display_type_field = 'format'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar
    #
    # set :index_range to true if you want the facet pagination view to have facet prefix-based navigation
    #  (useful when user clicks "more" on a large facet and wants to navigate alphabetically across a large set
    #  of results)
    # :index_range can be an array or range of prefixes that will be used to create the navigation
    # (note: It is case sensitive when searching values)

    config.add_facet_field 'presentation_set__facet', label: 'Presentation Set', limit: 10, collapse: false,
                                                     sort: 'index'
    config.add_facet_field 'admin_set__facet', label: 'Administrative Set', limit: 10, sort: 'index'
    config.add_facet_field 'resource_type__facet', label: 'Resource Type', limit: 10
    config.add_facet_field 'rdf_type__facet', label: 'RDF Type', limit: 10
    config.add_facet_field 'visibility__facet', label: 'Visibility'
    config.add_facet_field 'publication_status__facet', label: 'Publication'

    # config.add_facet_field 'pub_date', label: 'Publication Year', single: true
    # config.add_facet_field 'subject_topic_facet', label: 'Topic', limit: 20, index_range: 'A'..'Z'
    # config.add_facet_field 'language_facet', label: 'Language', limit: true
    # config.add_facet_field 'lc_1letter_facet', label: 'Call Number'
    # config.add_facet_field 'subject_geo_facet', label: 'Region'
    # config.add_facet_field 'subject_era_facet', label: 'Era'

    # config.add_facet_field 'example_pivot_field', label: 'Pivot Field', pivot: %w(format language_facet)

    # config.add_facet_field 'example_query_facet_field', label: 'Publish Date', query: {
    #  years_5: { label: 'within 5 Years', fq: "pub_date:[#{Time.zone.now.year - 5} TO *]" },
    #  years_10: { label: 'within 10 Years', fq: "pub_date:[#{Time.zone.now.year - 10} TO *]" },
    #  years_25: { label: 'within 25 Years', fq: "pub_date:[#{Time.zone.now.year - 25} TO *]" }
    # }

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field 'id', label: 'Annotation', helper_method: :link_to_document_view, if:
    lambda { |_context, _field, document|
      document[:rdf_type].include?('oa:Annotation')
    }

    config.add_index_field 'resource_type__facet', label: 'Resource Type'
    config.add_index_field 'item__created_by__txt', label: 'Created By'
    config.add_index_field 'item__created__dt', label: 'Created'
    config.add_index_field 'item__last_modified__dt', label: 'Last Modified'

    # Have BL send the most basic highlighting parameters for you
    config.add_field_configuration_to_solr_request!

    # Solr fields to be displayed in the show (single result) view.
    # The ordering of the field names is the order of the display.
    #
    # Note that as of implementation of in-browser editing of descriptive metadata,
    # the only fields being displayed from Solr are those relating to structural,
    # administrative, and technical metadata.

    config.add_show_field 'publication_status__facet', label: 'Publication Status'
    config.add_show_field 'visibility__facet', label: 'Visibility'
    config.add_show_field 'presentation_set__facet', label: 'Presentation Set', helper_method: :value_list
    config.add_show_field 'item__member_of__uri', label: 'Member Of', helper_method: :parent_from_subquery
    config.add_show_field 'item__has_member__uris', label: 'Members', helper_method: :members_from_subquery
    config.add_show_field 'item__created_by__txt', label: 'Created By'
    config.add_show_field 'item__created__dt', label: 'Created'
    config.add_show_field 'item__last_modified__dt', label: 'Last Modified'
    config.add_show_field 'rdf_type__facet', label: 'RDF Type', helper_method: :value_list

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.

    config.add_search_field 'all_fields', label: 'All Fields'

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc, item__title__txt asc', label: 'relevance'
    # config.add_sort_field 'pub_date_sort desc, title_sort asc', label: 'year'
    # config.add_sort_field 'author_sort asc, title_sort asc', label: 'author'
    # config.add_sort_field 'title_sort asc, pub_date_sort desc', label: 'title'

    config.add_sort_field 'item__title__txt asc', label: 'title'
    config.add_sort_field 'item__created__dt asc', label: 'created (oldest to newest)'
    config.add_sort_field 'item__created__dt desc', label: 'created (newest to oldest)'
    config.add_sort_field 'item__last_modified__dt asc', label: 'last modified (oldest to newest)'
    config.add_sort_field 'item__last_modified__dt desc', label: 'last modified (newest to oldest)'

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

    # Configuration for autocomplete suggestor
    config.autocomplete_enabled = true
    config.autocomplete_path = 'suggest'
  end

  # get search results from the solr index
  def index
    fix_query_param
    # Use 'search' for regular searches, and 'identifier_search' for identifier searches.
    is_identifier_search = identifier_search?(params[:q])
    blacklight_config[:solr_path] = is_identifier_search ? 'identifier_search' : 'search'
    super
    return unless is_identifier_search && @response.response['numFound'] == 1

    redirect_to action: 'show', id: @document_list[0].id
  end

  def show
    super
    @show_edit_metadata = CatalogController.show_edit_metadata(@document['component'])
    @id = params[:id]
    @resource = ResourceService.resource_with_model(@id)
    @published = @resource[:items][@id]['@type'].include?('http://vocab.lib.umd.edu/access#Published')
  end

  # Returns true if the given component has editable metadata, false otherwise.
  def self.show_edit_metadata(component)
    uneditable_types = %w[Page Article]
    !uneditable_types.include?(component)
  end

  private

    def goto_about_page(err)
      solr_connection_error(err)
      redirect_to(about_url)
    end

    def make_current_query_accessible
      @current_query = params[:q]
    end

    def collection_facet_selected?
      params[:f] && params[:f][:collection_title_facet]
    end

    # Solr does not escape ':' character when using single quotes. Replace
    # single quotes with double quotes to ensure ':" characters in identifiers
    # are not misidentified. For instance, a pid query in single quote, such as
    # 'umd:123', will cause solr to look for a solr field with name "umd"
    # leading to a 400 response.
    def fix_query_param
      params[:q] = params[:q] ? params[:q].tr("'", '"') : ''
    end

    def identifier_search?(query)
      # Check if this is a identifier search
      #  1. the query is enclosed in quotation marks.
      #  2. And, it does not have blank spaces
      query.present? && query.start_with?('"') && query.end_with?('"') && !query.include?(' ')
    end
end

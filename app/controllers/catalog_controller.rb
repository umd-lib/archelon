# frozen_string_literal: true

# Blacklight controller that handles searches and document requests
class CatalogController < ApplicationController

  include Blacklight::Catalog

  # UMD Customization
  rescue_from Blacklight::Exceptions::ECONNREFUSED, with: :goto_about_page
  rescue_from Blacklight::Exceptions::InvalidRequest, with: :goto_about_page
  # End UMD Customization

  # If you'd like to handle errors returned by Solr in a certain way,
  # you can use Rails rescue_from with a method you define in this controller,
  # uncomment:
  #
  # rescue_from Blacklight::Exceptions::InvalidRequest, with: :my_handling_method

  configure_blacklight do |config|
    ## Specify the style of markup to be generated (may be 4 or 5)
    # config.bootstrap_version = 5
    #
    ## Class for sending and receiving requests from a search index
    # config.repository_class = Blacklight::Solr::Repository
    #
    ## Class for converting Blacklight's url parameters to into request parameters for the search index
    # config.search_builder_class = ::SearchBuilder
    #
    ## Model that maps search index responses to the blacklight response model
    # config.response_model = Blacklight::Solr::Response
    #
    ## The destination for the link around the logo in the header
    # config.logo_link = root_path
    #
    ## Should the raw solr document endpoint (e.g. /catalog/:id/raw) be enabled
    # config.raw_endpoint.enabled = false

    ## Default parameters to send to solr for all search-like requests. See also SearchBuilder#processed_parameters
    config.default_solr_params = {
      rows: 10,
      # UMD Customization
      fq: ['is_pcdm:true']
      # End UMD Customization
    }

    # solr path which will be added to solr base url before the other solr params.
    # UMD Customization
    config.solr_path = 'search'
    config.document_solr_path = 'document'
    # End UMD Customization
    #config.json_solr_path = 'advanced'

    # items to show per page, each number in the array represent another option to choose from.
    #config.per_page = [10,20,50,100]

    # solr field configuration for search results/index views
    # UMD Customization
    config.index.title_field = 'display_title'
    # End UMD Customization
    # config.index.display_type_field = 'format'
    # config.index.thumbnail_field = 'thumbnail_path_ss'

    # The presenter is the view-model class for the page
    # config.index.document_presenter_class = MyApp::IndexPresenter

    # Some components can be configured
    # config.index.document_component = MyApp::SearchResultComponent
    # config.index.constraints_component = MyApp::ConstraintsComponent
    # config.index.search_bar_component = MyApp::SearchBarComponent
    # config.index.search_header_component = MyApp::SearchHeaderComponent
    # config.index.document_actions.delete(:bookmark)

    config.add_results_document_tool(:bookmark, component: Blacklight::Document::BookmarkComponent, if: :render_bookmarks_control?)

    config.add_results_collection_tool(:sort_widget)
    config.add_results_collection_tool(:per_page_widget)
    config.add_results_collection_tool(:view_type_group)

    config.add_show_tools_partial(:bookmark, component: Blacklight::Document::BookmarkComponent, if: :render_bookmarks_control?)
    config.add_show_tools_partial(:email, callback: :email_action, validator: :validate_email_params)
    config.add_show_tools_partial(:sms, if: :render_sms_action?, callback: :sms_action, validator: :validate_sms_params)
    config.add_show_tools_partial(:citation)

    config.add_nav_action(:bookmark, partial: 'blacklight/nav/bookmark', if: :render_bookmarks_control?)
    config.add_nav_action(:search_history, partial: 'blacklight/nav/search_history')

    # solr field configuration for document/show views
    # UMD Customization
    config.show.title_field = 'display_title'
    # End UMD Customization
    # config.show.display_type_field = 'format'
    # config.show.thumbnail_field = 'thumbnail_path_ss'
    #
    # The presenter is a view-model class for the page
    # config.show.document_presenter_class = MyApp::ShowPresenter
    #
    # These components can be configured
    # config.show.document_component = MyApp::DocumentComponent
    # config.show.sidebar_component = MyApp::SidebarComponent
    # config.show.embed_component = MyApp::EmbedComponent

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
    #  (useful when user clicks "more" on a large facet and wants to navigate alphabetically across a large set of results)
    # :index_range can be an array or range of prefixes that will be used to create the navigation (note: It is case sensitive when searching values)

    # UMD Customization
    config.add_facet_field 'presentation_set_label', label: 'Presentation Set', limit: 10, collapse: false,
                                                     sort: 'index'
    config.add_facet_field 'collection_title_facet', label: 'Administrative Set', limit: 10, sort: 'index'
    config.add_facet_field 'author_not_tokenized', label: 'Author', limit: 10
    config.add_facet_field 'type', label: 'Type', limit: 10
    config.add_facet_field 'component_not_tokenized', label: 'Resource Type', limit: 10
    config.add_facet_field 'rdf_type', label: 'RDF Type', limit: 10
    config.add_facet_field 'visibility', label: 'Visibility'
    config.add_facet_field 'publication_status', label: 'Publication'
    # config.add_facet_field 'format', label: 'Format'
    # config.add_facet_field 'pub_date_ssim', label: 'Publication Year', single: true
    # config.add_facet_field 'subject_ssim', label: 'Topic', limit: 20, index_range: 'A'..'Z'
    # config.add_facet_field 'language_ssim', label: 'Language', limit: true
    # config.add_facet_field 'lc_1letter_ssim', label: 'Call Number'
    # config.add_facet_field 'subject_geo_ssim', label: 'Region'
    # config.add_facet_field 'subject_era_ssim', label: 'Era'

    # config.add_facet_field 'example_pivot_field', label: 'Pivot Field', pivot: ['format', 'language_ssim'], collapsing: true

    # config.add_facet_field 'example_query_facet_field', label: 'Publish Date', :query => {
    #    :years_5 => { label: 'within 5 Years', fq: "pub_date_ssim:[#{Time.zone.now.year - 5 } TO *]" },
    #    :years_10 => { label: 'within 10 Years', fq: "pub_date_ssim:[#{Time.zone.now.year - 10 } TO *]" },
    #    :years_25 => { label: 'within 25 Years', fq: "pub_date_ssim:[#{Time.zone.now.year - 25 } TO *]" }
    # }
    # End UMD Customization


    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    # UMD Customization
    # config.add_index_field 'title_tsim', label: 'Title'
    # config.add_index_field 'title_vern_ssim', label: 'Title'
    # config.add_index_field 'author_tsim', label: 'Author'
    # config.add_index_field 'author_vern_ssim', label: 'Author'
    # config.add_index_field 'format', label: 'Format'
    # config.add_index_field 'language_ssim', label: 'Language'
    # config.add_index_field 'published_ssim', label: 'Published'
    # config.add_index_field 'published_vern_ssim', label: 'Published'
    # config.add_index_field 'lc_callnum_ssim', label: 'Call number'
    config.add_index_field 'id', label: 'Annotation', helper_method: :link_to_document_view, if:
    lambda { |_context, _field, document|
      document[:rdf_type].include?('oa:Annotation')
    }
    config.add_index_field 'component', label: 'Resource Type'
    config.add_index_field 'author', label: 'Author'
    config.add_index_field 'extracted_text', label: 'OCR', highlight: true, helper_method: :format_extracted_text, solr_params: { 'hl.fragsize' => 500 }
    config.add_index_field 'created_by', label: 'Created By'
    config.add_index_field 'created', label: 'Created'
    config.add_index_field 'last_modified', label: 'Last Modified'

    # Have BL send the most basic highlighting parameters for you
    config.add_field_configuration_to_solr_request!
    # End UMD Customization

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    # UMD Customization
    # config.add_show_field 'title_tsim', label: 'Title'
    # config.add_show_field 'title_vern_ssim', label: 'Title'
    # config.add_show_field 'subtitle_tsim', label: 'Subtitle'
    # config.add_show_field 'subtitle_vern_ssim', label: 'Subtitle'
    # config.add_show_field 'author_tsim', label: 'Author'
    # config.add_show_field 'author_vern_ssim', label: 'Author'
    # config.add_show_field 'format', label: 'Format'
    # config.add_show_field 'url_fulltext_ssim', label: 'URL'
    # config.add_show_field 'url_suppl_ssim', label: 'More Information'
    # config.add_show_field 'language_ssim', label: 'Language'
    # config.add_show_field 'published_ssim', label: 'Published'
    # config.add_show_field 'published_vern_ssim', label: 'Published'
    # config.add_show_field 'lc_callnum_ssim', label: 'Call number'
    # config.add_show_field 'isbn_ssim', label: 'ISBN'

    config.add_show_field 'pcdm_collection', label: 'Collection', helper_method: :collection_from_subquery
    config.add_show_field 'publication_status', label: 'Publication Status'
    config.add_show_field 'visibility', label: 'Visibility'
    config.add_show_field 'presentation_set_label', label: 'Presentation Set', helper_method: :value_list
    config.add_show_field 'pcdm_member_of', label: 'Member Of', helper_method: :parent_from_subquery
    config.add_show_field 'pcdm_members', label: 'Members', helper_method: :members_from_subquery
    config.add_show_field 'pcdm_related_object_of', label: 'Related To', helper_method: :related_object_of_from_subquery
    config.add_show_field 'pcdm_related_objects', label: 'Related Objects', helper_method: :related_objects_from_subquery
    config.add_show_field 'pcdm_file_of', label: 'File Of', helper_method: :file_parent_from_subquery
    config.add_show_field 'pcdm_files', label: 'Files', helper_method: :files_from_subquery
    config.add_show_field 'annotation_source', label: 'Pages', helper_method: :annotation_source_from_subquery
    config.add_show_field 'size', label: 'Size'
    config.add_show_field 'mime_type', label: 'Mime Type'
    config.add_show_field 'digest', label: 'Digest'
    config.add_show_field 'created_by', label: 'Created By'
    config.add_show_field 'created', label: 'Created'
    config.add_show_field 'last_modified', label: 'Last Modified'
    config.add_show_field 'rdf_type', label: 'RDF Type', helper_method: :value_list
    # End UMD Customization

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


    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.

    # UMD Customization
    # config.add_search_field('title') do |field|
    #   # solr_parameters hash are sent to Solr as ordinary url query params.
    #   field.solr_parameters = {
    #     'spellcheck.dictionary': 'title',
    #     qf: '${title_qf}',
    #     pf: '${title_pf}'
    #   }
    # end

    # config.add_search_field('author') do |field|
    #   field.solr_parameters = {
    #     'spellcheck.dictionary': 'author',
    #     qf: '${author_qf}',
    #     pf: '${author_pf}'
    #   }
    # end

    # # Specifying a :qt only to show it's possible, and so our internal automated
    # # tests can test it. In this case it's the same as
    # # config[:default_solr_parameters][:qt], so isn't actually neccesary.
    # config.add_search_field('subject') do |field|
    #   field.qt = 'search'
    #   field.solr_parameters = {
    #     'spellcheck.dictionary': 'subject',
    #     qf: '${subject_qf}',
    #     pf: '${subject_pf}'
    #   }
    # end
    # End UMD Customization

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the Solr field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case). Add the sort: option to configure a
    # custom Blacklight url parameter value separate from the Solr sort fields.
    # UMD Customization
    # config.add_sort_field 'relevance', sort: 'score desc, pub_date_si desc, title_si asc', label: 'relevance'
    # config.add_sort_field 'year-desc', sort: 'pub_date_si desc, title_si asc', label: 'year'
    # config.add_sort_field 'author', sort: 'author_si asc, title_si asc', label: 'author'
    # config.add_sort_field 'title_si asc, pub_date_si desc', label: 'title'
    config.add_sort_field 'score desc, display_title asc', label: 'relevance'
    config.add_sort_field 'display_title asc', label: 'title'
    config.add_sort_field 'created asc', label: 'created (oldest to newest)'
    config.add_sort_field 'created desc', label: 'created (newest to oldest)'
    config.add_sort_field 'last_modified asc', label: 'last modified (oldest to newest)'
    config.add_sort_field 'last_modified desc', label: 'last modified (newest to oldest)'
    # End UMD Customization

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

    # Configuration for autocomplete suggester
    config.autocomplete_enabled = true
    config.autocomplete_path = 'suggest'
    # if the name of the solr.SuggestComponent provided in your solrconfig.xml is not the
    # default 'mySuggester', uncomment and provide it below
    # config.autocomplete_suggester = 'mySuggester'
  end
  private

    def goto_about_page(err)
      solr_connection_error(err)
      redirect_to(about_url)
    end


  # End UMD Customization
end

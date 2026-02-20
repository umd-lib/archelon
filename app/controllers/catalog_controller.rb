# frozen_string_literal: true

# Blacklight controller that handles searches and document requests
class CatalogController < ApplicationController # rubocop:disable Metrics/ClassLength
  include Blacklight::Catalog

  # UMD Customization
  before_action :make_current_query_accessible, only: %i[show index]

  # Override search_state_class in Blacklight::Controller to customize searches
  self.search_state_class = UmdSearchState

  unless Rails.env.development?
    rescue_from Blacklight::Exceptions::ECONNREFUSED, with: :goto_about_page
    rescue_from Blacklight::Exceptions::InvalidRequest, with: :goto_about_page
  end
  # End UMD Customization

  # If you'd like to handle errors returned by Solr in a certain way,
  # you can use Rails rescue_from with a method you define in this controller,
  # uncomment:
  #
  # rescue_from Blacklight::Exceptions::InvalidRequest, with: :my_handling_method

  # rubocop:disable Layout/LineLength
  configure_blacklight do |config| # rubocop:disable Metrics/BlockLength
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
    config.default_solr_params = { fq: 'is_top_level:true' }

    # config.fetch_many_document_params = {}

    # solr path which will be added to solr base url before the other solr params.
    # UMD Customization
    config.solr_path = 'select'
    config.document_solr_path = 'select'

    # Default parameters to send on single-document requests to Solr. These settings are the Blacklight defaults (see
    # SearchHelper#solr_doc_params) or parameters included in the Blacklight-jetty document requestHandler.
    # config.default_document_solr_params = {}
    # End UMD Customization
    config.json_solr_path = nil

    # items to show per page, each number in the array represent another option to choose from.
    # config.per_page = [10,20,50,100]

    # UMD Customization

    # solr field configuration for search results/index views
    # config.index.title_field = 'object__title__txt'
    # End UMD Customization
    # config.index.display_type_field = 'format'
    config.index.thumbnail_field = 'iiif_thumbnail_sequence__uris'

    # The presenter is the view-model class for the page
    # config.index.document_presenter_class = MyApp::IndexPresenter

    # Some components can be configured
    # config.index.document_component = MyApp::SearchResultComponent
    # config.index.constraints_component = MyApp::ConstraintsComponent
    # config.index.search_bar_component = MyApp::SearchBarComponent
    # config.index.search_header_component = MyApp::SearchHeaderComponent
    config.show.sidebar_component = ArchelonSidebarComponent
    config.show.document_component = ArchelonDocumentComponent
    config.index.document_component = ArchelonDocumentComponent
    config.index.document_actions.delete(:bookmark)

    config.add_results_document_tool(:bookmark, component: Blacklight::Document::BookmarkComponent, if: :render_bookmarks_control?)

    config.add_results_collection_tool(:sort_widget)
    config.add_results_collection_tool(:per_page_widget)
    # config.add_results_collection_tool(:view_type_group)

    config.add_show_tools_partial(:bookmark, component: Blacklight::Document::BookmarkComponent, if: :render_bookmarks_control?)
    # config.add_show_tools_partial(:sms, if: :render_sms_action?, callback: :sms_action, validator: :validate_sms_params)
    # config.add_show_tools_partial(:citation)

    config.add_nav_action(:bookmark, partial: 'blacklight/nav/bookmark', if: :render_bookmarks_control?)
    # config.add_nav_action(:search_history, partial: 'blacklight/nav/search_history')
    blacklight_config.max_per_page = 1000

    # solr field configuration for document/show views
    # UMD Customization
    config.show.title_field = 'object__title__txt'
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
    config.add_facet_field 'presentation_set__facet', label: 'Presentation Set', limit: 10, sort: 'index'
    config.add_facet_field 'archival_collection__facet', label: 'Archival Collection', component: FilterFacetComponent
    config.add_facet_field 'creator__facet', label: 'Creator', component: FilterFacetComponent
    config.add_facet_field 'resource_type__facet', label: 'Resource Type', limit: 10
    config.add_facet_field 'subject__facet', label: 'Subject', limit: 10
    config.add_facet_field 'rights__facet', label: 'Rights Statement', limit: 10
    config.add_facet_field 'censorship__facet', label: 'Censored', if: :show_censorship_facet?
    config.add_facet_field 'publication_status__facet', label: 'Publication'
    config.add_facet_field 'has_ocr__facet', label: 'Has OCR'
    # "For DPI Use" facet fields
    config.add_facet_field 'admin_set__facet', label: 'Administrative Set', limit: 10, sort: 'index', if: :show_dpi_use_facets?
    config.add_facet_field 'visibility__facet', label: 'Visibility', if: :show_dpi_use_facets?
    config.add_facet_field 'rdf_type__facet', label: 'RDF Type', limit: 10, if: :show_dpi_use_facets?

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
    config.add_index_field 'extracted_text__dps_txt', label: 'Text Content', accessor: :extracted_text, component: ExtractedTextMetadataComponent
    config.add_index_field 'object__date__edtf', label: 'Date'
    config.add_index_field 'object__description__txt', label: 'Description'
    config.add_index_field 'resource_type__facet', label: 'Resource Type'
    config.add_index_field 'page_count__int', label: 'Number of Pages'
    config.add_index_field 'object__archival_collection__label__txt', label: 'Archival Collection'
    config.add_index_field 'creator__facet', label: 'Creator'

    # Have BL send the most basic highlighting parameters for you
    config.add_field_configuration_to_solr_request!
    # End UMD Customization

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
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

    # UMD Customization

    # Item Level Fields
    config.add_show_field 'object__title__display', label: 'Title', accessor: :title_language_badge, component: ListMetadataComponent
    config.add_show_field 'object__alternate_title__display', label: 'Alternate Title', accessor: :alternate_title_language_badge, component: ListMetadataComponent
    config.add_show_field 'object__volume__txt', label: 'Volume'
    config.add_show_field 'object__issue__txt', label: 'Issue'
    config.add_show_field 'object__edition__txt', label: 'Edition'
    config.add_show_field 'object__identifier__ids', label: 'Identifier', component: ListMetadataComponent
    config.add_show_field 'object__accession_number__id', label: 'Accession Number'
    config.add_show_field 'handle__id', label: 'Handle', accessor: :handle_anchor
    config.add_show_field 'object__creator', label: 'Creator', accessor: :creator_language_badge, component: ListMetadataComponent
    config.add_show_field 'object__contributor', label: 'Contributor', accessor: :contributor_language_badge, component: ListMetadataComponent
    config.add_show_field 'object__audience', label: 'Audience', accessor: :audience_language_badge, component: ListMetadataComponent
    config.add_show_field 'publisher__facet', label: 'Publisher', component: ListMetadataComponent
    config.add_show_field 'object__date__edtf', label: 'Date'
    config.add_show_field 'object__description__txt', label: 'Description'

    # pair with object__archival_collection__label__txt
    # pair with object__archival_collection__same_as__uris
    config.add_show_field 'object__archival_collection__uri', label: 'Archival Collection', accessor: :archival_collection_links, component: ListMetadataComponent

    config.add_show_field 'object__bibliographic_citation__txt', label: 'Collection Information'
    config.add_show_field 'object__format__uri', label: 'Format', accessor: :format_anchor
    config.add_show_field 'object__object_type__uri', label: 'Object Type', accessor: :object_type_anchor

    # pair with object__rights__label__txt
    config.add_show_field 'object__rights__uri', label: 'Rights Statement', accessor: :rights_anchor
    config.add_show_field 'object__rights_holder', label: 'Rights Holder', accessor: :rights_holder_language_badge, component: ListMetadataComponent

    config.add_show_field 'object__terms_of_use__value__txt', label: 'Terms of Use', accessor: :terms_of_use
    config.add_show_field 'location__facet', label: 'Location', component: ListMetadataComponent
    config.add_show_field 'subject__facet', label: 'Subject', accessor: :subject_facet_links, component: ListMetadataComponent
    config.add_show_field 'object__extent__txts', label: 'Extent'
    config.add_show_field 'language__facet', label: 'Language', component: ListMetadataComponent
    config.add_show_field 'publication_status__facet', label: 'Publication Status'
    config.add_show_field 'visibility__facet', label: 'Visibility'
    config.add_show_field 'presentation_set__facet', label: 'Presentation Set', component: ListMetadataComponent
    config.add_show_field 'admin_set__facet', label: 'Member Of'
    config.add_show_field 'page_uri_sequence__uris', label: 'Members', accessor: :members_anchor, component: ListMetadataComponent
    config.add_show_field 'object__created_by__str', label: 'Created By'
    config.add_show_field 'object__created__dt', label: 'Created'
    config.add_show_field 'object__last_modified_by__str', label: 'Last Modified By'
    config.add_show_field 'object__last_modified__dt', label: 'Last Modified'
    config.add_show_field 'rdf_type__facet', label: 'RDF Type', component: ListMetadataComponent

    # Page Level Fields
    config.add_show_field 'page__title__txt', label: 'Page'
    config.add_show_field 'page__member_of__uri', label: 'Member Of', backlink_text_accessor: 'display_titles', component: ArchelonBacklinkComponent
    config.add_show_field 'page__has_file__uris', label: 'Files', component: ListMetadataComponent
    config.add_show_field 'page__rdf_type__curies', label: 'RDF Types', component: ListMetadataComponent

    # File Level Fields
    config.add_show_field 'file__title__txt', label: 'Title'
    config.add_show_field 'file__file_of__uri', label: 'File Of', backlink_text_field: 'page__title__txt', component: ArchelonBacklinkComponent
    config.add_show_field 'file__size__int', label: 'Size'
    config.add_show_field 'file__mime_type__txt', label: 'Mime Type'
    config.add_show_field 'file__checksum__uri', label: 'Digest'
    config.add_show_field 'file__rdf_type__uris', label: 'RDF Types', component: ListMetadataComponent

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

    config.add_search_field('text') do |field|
      field.label = 'Text & Metadata'
      field.solr_parameters = {
        qf: 'extracted_text__dps_txt text',
        defType: 'edismax',
        hl: true,
        'hl.fl': 'extracted_text__dps_txt',
        'hl.snippets': 5,
        'hl.fragsize': 50,
        'hl.maxAnalyzedChars': 1_000_000,
        'hl.tag.pre': SolrDocument::HL_START_CHAR,
        'hl.tag.post': SolrDocument::HL_END_CHAR
      }
    end

    config.add_search_field('identifier') do |field|
      field.label = 'Identifier Lookup'
      field.solr_parameters = { df: 'identifier', defType: 'edismax', 'q:alt': '*:*' }
    end

    # For the subject and location searches, use the parent query parser to return
    # the parent documents of the documents that match the given query.
    # See also the Solr documentation here:
    # https://solr.apache.org/guide/solr/9_6/query-guide/searching-nested-documents.html#parent-query-parser

    config.add_search_field('subject') do |field|
      field.label = 'Subject'
      field.solr_parameters = { df: 'subject__label__txt' }
      field.solr_local_parameters = { type: 'parent', which: '*:* -_nest_path_:*' }
    end

    config.add_search_field('location') do |field|
      field.label = 'Location'
      field.solr_parameters = { df: 'place__label__txt' }
      field.solr_local_parameters = { type: 'parent', which: '*:* -_nest_path_:*' }
    end

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
    config.add_sort_field 'object__title__display asc', label: 'Title (Ascending)'
    config.add_sort_field 'object__title__display desc', label: 'Title (Descending)'

    config.add_sort_field 'object__created__time asc', label: 'Created Date (Ascending)'
    config.add_sort_field 'object__created__time desc', label: 'Created Date (Descending)'

    config.add_sort_field 'object__last_modified__time asc', label: 'Last Modified Date (Ascending)'
    config.add_sort_field 'object__last_modified__time desc', label: 'Last Modified Date (Descending)'

    # End UMD Customization

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

    # Configuration for autocomplete suggester
    # config.autocomplete_enabled = true
    # config.autocomplete_path = 'suggest'
    # if the name of the solr.SuggestComponent provided in your solrconfig.xml is not the
    # default 'mySuggester', uncomment and provide it below
    # config.autocomplete_suggester = 'mySuggester'
  end
  # rubocop:enable Layout/LineLength

  # UMD Customization

  # get search results from the solr index
  def index
    super
    redirect_to action: 'show', id: first_result['id'] if identifier_search? && single_result?
    clear_search_session if params.keys.sort == %w[action controller search_field]
  end

  def show # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    if request.headers['HX-Request'] == 'true'
      swap = params[:swap]
      document = search_service.fetch(params[:id])

      raise ActionController::BadRequest, 'Invalid part of the page to swap' unless %w[title metadata].include?(swap)

      if swap == 'title'
        render inline: '<span itemprop="name"><%= title %></span>', locals: { title: @document.display_titles } # rubocop:disable Rails/RenderInline
      else
        doc_presenter = view_context.document_presenter(document)

        render html: view_context.render(
          Blacklight::DocumentMetadataComponent.new(fields: doc_presenter.field_presenters)
        )
      end
    else
      super
    end
  end

  def updated
    document = search_service.fetch(params[:id])

    client_version = request.headers['If-None-Match']
    current_version = document['_version_'].to_s

    if client_version == current_version
      head :not_modified
    else
      render json: { new_version: current_version }, status: :ok
    end
  end

  private

    def clear_search_session
      params.delete(:search_field)
      redirect_to action: 'index'
    end

    def goto_about_page(err)
      solr_connection_error(err)
      redirect_to(about_url)
    end

    def make_current_query_accessible
      @current_query = params[:q] || Search.find(session.dig('search', 'id')).query_params['q']
    rescue ActiveRecord::RecordNotFound
      @current_query = nil
    end

    def collection_facet_selected?
      params[:f] && params[:f][:collection_title_facet]
    end

    def single_result?
      # True if there is exactly one result found by the current search
      @response.response['numFound'] == 1
    end

    def first_result
      # Get the first result; returns nil if there were no results
      @response.response['docs'].first
    end

    def identifier_search?
      # Check if this is a identifier search
      params[:search_field] == 'identifier'
    end

    def show_dpi_use_facets?
      current_cas_user.admin?
    end

    def facets_include?(name, value = nil)
      facet_param = params.dig(:f, name)
      return facet_param.present? if value.blank?

      facet_param.present? && facet_param.include?(value)
    end

    def show_censorship_facet?
      facets_include?(:censorship__facet) || facets_include?(:presentation_set__facet, "Prange Children's Books")
    end
  # End UMD Customization
end

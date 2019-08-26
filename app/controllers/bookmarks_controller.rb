# frozen_string_literal: true

class BookmarksController < CatalogController
  include Blacklight::Bookmarks

  # Remove relevance sort
  # Note: The "score desc, display_title asc" key has to match
  # the add_sort_field configuration for relevance sort field
  # in CatalogController configuration
  blacklight_config.sort_fields.delete('score desc, display_title asc')

  # Hide Citation link in the Bookmarks view
  blacklight_config.show.document_actions[:citation].if = false

  # Bump max per page to 1000 for bookmarks
  blacklight_config.max_per_page = 1000

  add_show_tools_partial(:export, path: :new_export_job_url, modal: false)

  def select_all_results # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    search_params = current_search_session.query_params
    return redirect_back_to_catalog(params, search_params) unless current_user.bookmarks.count < 1000
    search_params['rows'] = params[:result_count]
    (@response, @document_list) = search_results(search_params)
    document_ids = @document_list.map(&:id)
    selected_ids = current_user.bookmarks.map(&:document_id)
    missing_ids = document_ids.reject { |doc_id| selected_ids.include?(doc_id) }
    select_ids = missing_ids.take(1000-current_user.bookmarks.count)
    if select_ids.length.zero?
      flash[:notice] = I18n.t(:already_selected)
    else
      select_ids.each do |id|
        bookmark = { document_id: id, document_type: blacklight_config.document_model.to_s }
        current_user.bookmarks.create(bookmark)
      end
      flash[:notice] = I18n.t(:items_selected, selected_count: select_ids.length)
    end
    redirect_back_to_catalog(params, search_params)
    end

  private
    def redirect_back_to_catalog(params, search_params)
    search_params[:per_page] = params[:per_page]
    search_params[:page] = params[:page]
    search_params.delete(:rows)
    redirect_to search_catalog_path(search_params)
  end
end

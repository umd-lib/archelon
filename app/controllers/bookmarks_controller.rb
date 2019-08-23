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

  add_show_tools_partial(:export, path: :new_export_job_url, modal: false)

  def select_all_results # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    search_params = current_search_session.query_params
    search_params['rows'] = params[:result_count]
    (@response, @document_list) = search_results(search_params)
    document_ids = @document_list.map(&:id)
    selected_ids = current_user.bookmarks.map(&:document_id)
    missing_ids = document_ids.reject { |doc_id| selected_ids.include?(doc_id) }
    if missing_ids.length.zero?
      flash[:notice] = I18n.t(:already_selected)
    else
      missing_ids.each do |id|
        bookmark = { document_id: id, document_type: blacklight_config.document_model.to_s }
        current_user.bookmarks.create(bookmark)
      end
      flash[:notice] = I18n.t(:all_items_selected)
    end
    search_params[:per_page] = params[:per_page]
    redirect_to search_catalog_path(search_params)
  end
end

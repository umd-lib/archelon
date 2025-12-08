# frozen_string_literal: true

class BookmarksController < CatalogController
  include Blacklight::Bookmarks

  # UMD Customization
  blacklight_config.add_show_tools_partial(:export, path: :new_export_job_url, modal: false)
  blacklight_config.add_show_tools_partial(:publish_job, path: :new_publish_job_url, modal: false, label: 'Publish')
  blacklight_config.add_show_tools_partial(:unpublish_job, path: :new_unpublish_job_url, modal: false,
                                                           label: 'Unpublish')

  def create
    if current_user.bookmarks.count >= max_limit
      if request.xhr?
        render(json: "Max selection limit reached: #{max_limit}", status: :forbidden)
      else
        flash[:error] = "Max selection limit reached: #{max_limit}"
        redirect_back fallback_location: bookmarks_path
      end

      return
    end
    super
  end

  def select_results
    return redirect_back_to_catalog(params, search_params) if current_user.bookmarks.count >= max_limit

    # Retrieving all ids from the search
    @response = current_search_results
    add_selected(@response.documents)

    redirect_back_to_catalog(params, current_search_session.query_params)
  end

  private

    def current_search_results
      search_service.search_results do |builder|
        builder.rows = params[:numFound].to_i
        builder.with(current_search_session.query_params)
      end
    end

    def documents_to_add(documents)
      selected_ids = current_user.bookmarks.map(&:document_id)
      missing_ids = documents.reject { |doc| selected_ids.include?(doc[:id]) }
      missing_ids.take(max_limit - current_user.bookmarks.count)
    end

    def add_selected(documents)
      selected_docs = documents_to_add(documents)

      flash[:notice] = I18n.t(:already_selected) && return unless selected_docs

      selected_docs.each do |doc|
        current_user.bookmarks.create(document_id: doc[:id], document_type: doc.class.to_s)
      end

      count = selected_docs.length
      flash[:notice] = I18n.t(:items_selected, selected_count: count, items: count == 1 ? 'item' : 'items')
    end

    def redirect_back_to_catalog(params, search_params)
      search_params[:per_page] = params[:per_page]
      search_params[:page] = params[:page]
      search_params.delete(:rows)

      redirect_to search_catalog_path(search_params)
    end

    def max_limit
      helpers.max_bookmarks_selection_limit
    end
  # End UMD Customization
end

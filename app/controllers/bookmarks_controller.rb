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

  def select_results # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    if current_user.bookmarks.count >= max_limit
      return redirect_back_to_catalog(params, search_params)
    end

    # Adding only the ids on the page
    if params.has_key? :ids
      add_selected(params[:ids])
      redirect_back_to_catalog(params, current_search_session.query_params)
    else
      # Retrieving all ids from the search
      (@response, _) = search_service.search_results do |builder|
        builder.rows = params[:numFound].to_i
        builder
      end

      document_ids = @response.documents.map(&:id)

      add_selected(document_ids)

      redirect_back_to_catalog(params, current_search_session.query_params)
    end
  end

  private

    def add_selected (document_ids) # rubocop:disable Metrics/AbcSize
      selected_ids = current_user.bookmarks.map(&:document_id)
      missing_ids = document_ids.reject { |doc_id| selected_ids.include?(doc_id) }
      select_ids = missing_ids.take(max_limit - current_user.bookmarks.count)

      if select_ids.length.zero?
        flash[:notice] = I18n.t(:already_selected)
      else
        select_ids.each do |id|
          current_user.bookmarks.create(document_id: id, document_type: blacklight_config.document_model.to_s)
        end

        count = select_ids.length
        flash[:notice] = I18n.t(:items_selected, selected_count: count, items: count == 1 ? 'item' : 'items')
      end
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

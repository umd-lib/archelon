# frozen_string_literal: true

require 'json/ld'

class ResourceController < ApplicationController
  before_action :set_resource

  def edit
    @title = ResourceService.display_title(@resource, @id)
    @page_title = "Editing: \"#{@title}\""
  end

  def update # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    if sparql_update.empty?
      # count an empty update as success
      flash[:notice] = t('resource_update_successful')
      render json: update_complete
    else
      plastron_rest_base_url = Addressable::URI.parse(ENV.fetch('PLASTRON_REST_BASE_URL', nil))
      repo_path = @id.gsub(FCREPO_BASE_URL, '/')
      plastron_resource_url = plastron_rest_base_url.join("resources#{repo_path}")
      begin
        response = HTTP.follow.headers(
          content_type: 'application/sparql-update'
        ).patch(
          plastron_resource_url,
          params: { model: @resource[:content_model_name] },
          body: sparql_update
        )
      rescue HTTP::ConnectionError
        @errors = [{ error: 'Unable to connect to server' }]
        return render error_display
      rescue HTTP::Error
        @errors = [{ error: 'System error' }]
        return render error_display
      end

      if response.status.success?
        flash.now[:notice] = t('resource_update_successful')
        return render json: update_complete
      end

      @errors = errors_from_problem_details(response.parse)
      render error_display
    end
  end

  def update_state
    result = update_command.new(uri: @id, user: current_user).call

    if result.error_occurred?
      flash[:error] = "Unable to update this item: #{result.error_message}"
    else
      # Solr indexing happends more slowly than a page refresh, so when the detail page is
      # immediately redirected to, the metadata it reads from Solr is usually out of date.
      flash[:notice] = 'Update submitted. Please note that you may need to refresh this page
        to see the updated publication status of this item.'
    end

    redirect_to solr_document_url(@id)
  end

  private

    def set_resource
      @id = params[:id]
      @resource = ResourceService.resource_with_model(@id)
    end

    def update_command
      case params[:command]
      when 'Publish'
        PlastronServices::Http::PublishItem
      when 'Publish Hidden'
        PlastronServices::Http::PublishHiddenItem
      when 'Unpublish'
        PlastronServices::Http::UnpublishItem
      else
        raise "Unknown command #{params[:command]}"
      end
    end

    def update_complete
      {
        state: 'update_complete',
        destination: solr_document_url(id: @id)
      }
    end

    def sparql_update
      return @sparql_update if @sparql_update

      delete_statements = params[:delete] || []
      insert_statements = params[:insert] || []
      return '' if delete_statements.empty? && insert_statements.empty?

      @sparql_update = "DELETE {\n#{delete_statements.join} } INSERT {\n#{insert_statements.join} } WHERE {}"
    end

    def errors_from_problem_details(problem)
      if problem['title'] == 'Content-model validation failed'
        problem['validation_errors'].collect { |k, v| { error: "#{k}: #{v}" } }
      else
        [{ error: problem['details'] }]
      end
    end

    def error_display
      html = render_to_string template: 'resource/_error_display', layout: false
      { json: { state: 'update_failed', errorHtml: html, errors: @errors } }
    end
end

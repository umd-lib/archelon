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
      response = send_to_plastron(@id, @resource[:content_model_name], sparql_update)

      if response.ok? && response.state == 'update_complete'
        flash[:notice] = t('resource_update_successful') # rubocop:disable Rails/ActionControllerFlashBeforeRender
        return render json: update_complete
      end

      @errors = response.parse_errors(@id)
      error_display = render_to_string template: 'resource/_error_display', layout: false
      render json: { state: 'update_failed', errorHtml: error_display, errors: @errors }
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

    def send_to_plastron(id, model, sparql_update) # rubocop:disable Metrics/MethodLength
      params_to_skip = %w[utf8 authenticity_token submit controller action]
      submission = params.to_unsafe_h
      params_to_skip.each { |key| submission.delete(key) }

      Rails.logger.debug { "Sending SPARQL query to Plastron: '#{sparql_update}'" }

      body = {
        uris: [id],
        sparql_update: sparql_update
      }

      # Send synchronously to STOMP
      begin
        stomp_message = StompService.synchronous_message(:jobs_synchronous, body.to_json, update_headers(model))
        PlastronMessage.new(stomp_message)
      rescue MessagingError => e
        PlastronExceptionMessage.new(e.message)
      end
    end

    def update_headers(model)
      {
        PlastronCommand: 'update',
        'PlastronArg-on-behalf-of': current_user.cas_directory_id,
        'PlastronArg-no-transactions': 'True',
        'PlastronArg-validate': 'True',
        'PlastronArg-model': model,
        PlastronJobId: "SYNCHRONOUS-#{SecureRandom.uuid}"
      }
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
end

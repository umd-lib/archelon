# frozen_string_literal: true

require 'json/ld'

class ResourceController < ApplicationController
  def edit
    @id = params[:id]
    @resource = ResourceService.resource_with_model(@id)
    @title = @resource[:items][@id]['http://purl.org/dc/terms/title']&.first&.fetch('@value', @id)
    @page_title = "Editing: \"#{@title}\""
  end

  def update # rubocop:disable Metrics/AbcSize, Metrics/MethodLength,  Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/LineLength
    @id = params[:id]
    resource = ResourceService.resource_with_model(@id)

    delete_statements = (params[:delete] || [])
    insert_statements = (params[:insert] || [])

    if delete_statements.empty? && insert_statements.empty?
      # Go back to the edit page, if there are no changes
      messages = [t('resource_update_no_change')]
      render json: { messages: messages }
      return
    end

    @sparql_update = "DELETE {\n#{delete_statements.join} } INSERT {\n#{insert_statements.join} } WHERE {}"

    response = send_to_plastron(@id, resource[:content_model_name], @sparql_update)

    success = response[:status] == 'Done'

    if success
      flash[:notice] = t('resource_update_successful')
      redirect_to solr_document_url(id: @id)
    else
      validation_errors = response[:errors]
      @errors = []
      if validation_errors.present?
        validation_errors_from_json = JSON.parse(validation_errors[0].to_s)
        @errors = validation_errors_from_json
      end
      error_display = render_to_string template: 'resource/_error_display', layout: false
      return render json: { error_display: error_display }
    end
  end

  private

    def plastron_model_from_rdf_type(types)
      if types.include? 'http://purl.org/ontology/bibo/Issue'
        'Issue'
      elsif types.include? 'http://purl.org/ontology/bibo/Letter'
        'Letter'
      elsif types.include? 'http://purl.org/ontology/bibo/Image'
        'Poster'
      else
        'Item'
      end
    end

    def send_to_plastron(id, model, sparql_update) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      params_to_skip = %w[utf8 authenticity_token submit controller action]
      submission = params.to_unsafe_h
      params_to_skip.each { |key| submission.delete(key) }

      Rails.logger.debug("Sending SPARQL query to Plastron: '#{sparql_update}'")

      body = {
        uri: [id],
        sparql_update: sparql_update
      }

      body_json = body.to_json

      headers = {
        PlastronCommand: 'update',
        'PlastronArg-on-behalf-of': current_user.cas_directory_id,
        'PlastronArg-no-transactions': 'True',
        'PlastronArg-validate': 'False',
        'PlastronArg-model': model
      }

      begin
        # Send STOMP message synchronously
        response_message = StompService.synchronous_message(:jobs_synchronous, body_json, headers)
        status = response_message.headers['PlastronJobStatus']
        errors = [response_message.headers['PlastronJobError']]
      rescue Timeout::Error
        # Handle timeout
        status = 'Error'
        errors = [JSON.generate([I18n.t('resource_update_timeout_error')])]
      end
      { status: status, errors: errors }
    end
end

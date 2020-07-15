# frozen_string_literal: true

require 'json/ld'

class ResourceController < ApplicationController
  def edit
    @id = params[:id]
    @simulate = params[:simulate]

    resource_model = resource_model(@id)
    @items = resource_model[:items]

    @content_model = resource_model[:content_model]
  end

  def resource_model(id)
    # create a hash of resources by their URIs
    items = Hash[resources(id).map do |resource|
      uri = resource.delete('@id')
      [uri, resource]
    end]

    content_model = content_model_from_rdf_type(items[id]['@type'])
    { items: items, content_model: content_model }
  end

  def update # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/LineLength
    @id = params[:id]
    @simulate = params[:simulate]
    send_to_plastron if @simulate

    delete_statements = (params[:delete] || [])
    insert_statements = (params[:insert] || [])

    if delete_statements.empty? && insert_statements.empty?
      # Go back to the edit page, if there are no changes
      flash[:error] = t('resource_update_no_change')
      redirect_to(resource_edit_url(id: @id), turbolinks: false) && return
    end

    @sparql_update = "DELETE {\n#{delete_statements.join} } INSERT {\n#{insert_statements.join} } WHERE {}"

    response = send_to_plastron(@id, @sparql_update)

    success = response[:status] == 'Done'

    if success
      flash[:notice] = t('resource_update_successful')
      redirect_to solr_document_url(id: @id)
    else
      flash[:error] = t('resource_update_failed')
      @errors = response[:errors]

      @items = update_items(@id, delete_statements, insert_statements)
      @content_model = content_model_from_rdf_type(@items[@id]['@type'])
      render :edit
    end
  end

  private

    # Updates the given items, based on the given delete and insert statements
    def update_items(id, _delete_statements, _insert_statements)
      resource_model = resource_model(id)
      items = resource_model[:items]

      # TODO: Do someting here that takes the items, updates them based on
      # the delete and insert statements and returns them
      #
      # Right now, just returning the list of items, without change

      items
    end

    def content_model_from_rdf_type(types)
      if types.include? 'http://purl.org/ontology/bibo/Issue'
        ContentModels::NEWSPAPER
      elsif types.include? 'http://purl.org/ontology/bibo/Letter'
        ContentModels::LETTER
      elsif types.include? 'http://purl.org/ontology/bibo/Image'
        ContentModels::POSTER
      else
        ContentModels::ITEM
      end
    end

    def resources(uri)
      response = HTTP[accept: 'application/ld+json'].get(uri, ssl_context: SSL_CONTEXT)
      input = JSON.parse(response.body.to_s)
      JSON::LD::API.expand(input)
    end

    def send_to_plastron(id, sparql_update) # rubocop:disable Metrics/MethodLength
      params_to_skip = %w[utf8 authenticity_token submit controller action]
      submission = params.to_unsafe_h
      params_to_skip.each { |key| submission.delete(key) }

      body = {
        uri: [id],
        sparql_update: sparql_update
      }

      body_json = body.to_json

      headers = {
        PlastronCommand: 'update',
        'PlastronArg-no-transactions': 'True',
        'PlastronArg-recursive': 'False'
      }

      begin
        # Send STOMP message synchronously
        response_message = StompService.synchronous_message(:jobs_synchronous, body_json, headers)
        status = response_message.headers['PlastronJobStatus']
        errors = [response_message.headers['PlastronJobError']]
      rescue Timeout::Error
        # Handle timeout
        status = 'Error'
        errors = ['Timeout']
      end
      { status: status, errors: errors }
    end
end

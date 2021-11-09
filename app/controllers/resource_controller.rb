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
        flash[:notice] = t('resource_update_successful')
        return render json: update_complete
      end

      @errors = parse_errors(response)
      error_display = render_to_string template: 'resource/_error_display', layout: false
      render json: { state: 'update_failed', errorHtml: error_display, errors: @errors }
    end
  end

  private

    def set_resource
      @id = params[:id]
      @resource = ResourceService.resource_with_model(@id)
    end

    # Parses the strings returned as validation errors from Python, and
    # converts them into a map
    #
    # Errors from Plastron are expected to look like:
    # "('<name>', '<status>', '<rule>', '<expected>')"
    #
    # These errors are parsed into a Map with "name", "status", "rule", and
    # "expected" keys.
    #
    # Other errors (such as a timeout error) are just a simple string, and
    # are parsed into a Map that contains an "error" key.
    def parse_errors(response) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      stats = response.body_json['stats']
      validation_errors = stats['invalid'][@id]
      other_errors = stats['errors'][@id]
      errors = []

      [*validation_errors, *other_errors].each do |str|
        str = str.strip.gsub('(', '').gsub(')', '').gsub("'", '')
        arr = str.split(',').each(&:strip)

        if arr.length == 4
          h = { name: arr[0], status: arr[1], rule: arr[2], expected: arr[3] }
          # Workaround - "alternative" from Plastron should be "alternate_title"
          h[:name] = 'alternate_title' if h[:name] == 'alternative'
        else
          h = { error: str }
        end
        errors.append(h)
      end
      errors
    end

    def send_to_plastron(id, model, sparql_update)
      params_to_skip = %w[utf8 authenticity_token submit controller action]
      submission = params.to_unsafe_h
      params_to_skip.each { |key| submission.delete(key) }

      Rails.logger.debug("Sending SPARQL query to Plastron: '#{sparql_update}'")

      body = {
        uris: [id],
        sparql_update: sparql_update
      }

      # Send STOMP message synchronously
      StompService.synchronous_message(:jobs_synchronous, body.to_json, update_headers(model))
    end

    def update_headers(model)
      {
        PlastronCommand: 'update',
        'PlastronArg-on-behalf-of': current_user.cas_directory_id,
        'PlastronArg-no-transactions': 'True',
        'PlastronArg-validate': 'True',
        'PlastronArg-model': model
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

      delete_statements = (params[:delete] || [])
      insert_statements = (params[:insert] || [])
      return '' if delete_statements.empty? && insert_statements.empty?

      @sparql_update = "DELETE {\n#{delete_statements.join} } INSERT {\n#{insert_statements.join} } WHERE {}"
    end
end

# frozen_string_literal: true

require 'json/ld'

class ResourceController < ApplicationController
  def edit
    @id = params[:id]
    @resource = ResourceService.resource_with_model(@id)
    @title = ResourceService.display_title(@resource, @id)
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
        @errors = parse_errors(validation_errors_from_json)
      end
      error_display = render_to_string template: 'resource/_error_display', layout: false
      return render json: { error_display: error_display, errors: @errors }
    end
  end

  private

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
    def parse_errors(error_strings) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      errors = []

      error_strings.each do |str|
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
        'PlastronArg-validate': 'True',
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

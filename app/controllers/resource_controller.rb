# frozen_string_literal: true

require 'json/ld'

class ResourceController < ApplicationController
  def edit
    @id = params[:id]

    # create a hash of resources by their URIs
    @items = Hash[resources(@id).map do |resource|
      uri = resource.delete('@id')
      [uri, resource]
    end]

    @item = @items[@id]
    @content_model = content_model_from_rdf_type
  end

  def update # rubocop:disable Metrics/MethodLength
    params_to_skip = %w[utf8 authenticity_token submit controller action]
    submission = params.to_unsafe_h
    params_to_skip.each { |key| submission.delete(key) }
    submission_json = JSON.generate(submission)
    payload = submission_json

    headers = {
      PlastronCommand: 'echo',
      # Have Plastron delay the response by 2 seconds
      'echo-delay': 2
    }

    begin
      # Send STOMP message synchronously
      msg_response = StompService.synchronous_message(:jobs_synchronous, payload, headers)

      # Process response
      @json = msg_response.undump
      @submission = JSON.pretty_generate(JSON.parse(@json))
    rescue Timeout::Error
      # Handle timeout
      @submission = 'Error: Message timeout expired.'
    end

    render 'form_submit'
  end

  private

    def content_model_from_rdf_type
      if @item['@type'].include? 'http://purl.org/ontology/bibo/Issue'
        ContentModels::NEWSPAPER
      elsif @item['@type'].include? 'http://purl.org/ontology/bibo/Letter'
        ContentModels::LETTER
      elsif @item['@type'].include? 'http://purl.org/ontology/bibo/Image'
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
end

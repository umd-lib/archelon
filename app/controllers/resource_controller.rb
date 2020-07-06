# frozen_string_literal: true

require 'json/ld'

class ResourceController < ApplicationController
  def edit
    @id = params[:id]

    # create a hash of resources by their URIs
    items = Hash[resources(@id).map do |resource|
      uri = resource.delete('@id')
      [uri, resource]
    end]

    @item = items[@id]
    @content_model = content_model_from_rdf_type
  end

  def update
    render 'form_submit'
  end

  private

    def content_model_from_rdf_type
      if @item['@type'].include? 'http://purl.org/ontology/bibo/Issue'
        ContentModels::NEWSPAPER
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

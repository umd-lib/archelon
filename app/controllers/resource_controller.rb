# frozen_string_literal: true

require 'json/ld'

class ResourceController < ApplicationController
  def edit
    @id = params[:id]

    response = HTTP[accept: 'application/ld+json'].get(@id, ssl_context: SSL_CONTEXT)
    input = JSON.parse(response.body.to_s)


    resources = JSON::LD::API.expand(input)

    # create a hash of resources by their URIs
    items = Hash[resources.map do |resource|
      uri = resource.delete('@id')
      [uri, resource]
    end]

    @item = items[@id]
    @content_model = if @item['@type'].include? 'http://purl.org/ontology/bibo/Issue'
                       ContentModels::NEWSPAPER
                     else
                       ContentModels::ITEM
                     end
  end

  def update
    render 'form_submit'
  end
end

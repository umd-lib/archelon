# frozen_string_literal: true

require 'json/ld'

class ResourceController < ApplicationController
  def edit # rubocop:disable Metrics/AbcSize
    response = HTTP[accept: 'application/ld+json'].get(params[:id], ssl_context: SSL_CONTEXT)
    body = response.body.to_s
    input = JSON.parse(body)
    json_ld = JSON::LD::API.expand(input)

    @title = json_ld[0]['http://purl.org/dc/terms/title'][0]['@value']
    @date = json_ld[0]['http://purl.org/dc/elements/1.1/date'][0]['@value']
  end

  def update
    @params = params
    render 'form_submit'
  end
end

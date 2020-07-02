# frozen_string_literal: true

require 'json/ld'

class ResourceController < ApplicationController
  def edit # rubocop:disable Metrics/MethodLength
    response = HTTP[accept: 'application/ld+json'].get(params[:id], ssl_context: SSL_CONTEXT)
    body = response.body.to_s
    input = JSON.parse(body)
    context = {
      # prefixes
      bibo: 'http://purl.org/ontology/bibo/',
      dc: 'http://purl.org/dc/elements/1.1/',
      dcterms: 'http://purl.org/dc/terms/',
      fedora: 'http://fedora.info/definitions/v4/repository#',
      # fields
      title: 'dcterms:title',
      date: 'dc:date',
      volume: 'bibo:volume',
      issue: 'bibo:issue',
      edition: 'bibo:edition'
    }.with_indifferent_access

    @required_fields = [
      {
        name: 'title',
        label: 'Title',
        type: :PlainLiteral,
        repeatable: true
      }
    ]
    @recommended_fields = [
      {
        name: 'date',
        label: 'Date',
        type: :TypedLiteral
      }
    ]
    @optional_fields = [
      {
        name: 'volume',
        label: 'Volume',
        type: :TypedLiteral
      },
      {
        name: 'issue',
        label: 'Issue',
        type: :TypedLiteral
      },
      {
        name: 'edition',
        label: 'Edition',
        type: :TypedLiteral
      }
    ]
    @item = JSON::LD::API.compact(input, context)
  end

  def update
    @params = params
    render 'form_submit'
  end
end

# frozen_string_literal: true

class StaticPagesController < ApplicationController
  def about
    # A simple ping to SOLR to see if it's running
    uri = URI(ENV['SOLR_URL'])
    Net::HTTP.get(uri)
  rescue Errno::ECONNREFUSED => e
    solr_connection_error(e)
  rescue SocketError => e
    solr_connection_error(e)
  end

  private

    def solr_connection_error(err)
      Rails.logger.error(err.message)
      flash[:error] = I18n.t(:solr_is_down)
    end
end

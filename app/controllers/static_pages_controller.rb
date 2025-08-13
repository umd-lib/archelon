# frozen_string_literal: true

class StaticPagesController < ApplicationController
  def about
    # A simple ping to SOLR to see if it's running
    uri = URI(ENV.fetch('SOLR_URL', nil))
    # UMD Blacklight 8 Fix
    Net::HTTP.get(uri)
    # End UMD Blacklight 8 Fix
  rescue Errno::ECONNREFUSED => e
    solr_connection_error(e)
  rescue SocketError => e
    solr_connection_error(e)
  end
end

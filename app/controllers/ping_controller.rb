# frozen_string_literal: true

# Controller for network monitoring to use to determine whether the
# application is running and the database is reachable.
class PingController < ApplicationController
  # Controller actions should be accessible without requiring authentication.
  skip_before_action :authenticate

  def verify
    # attempt to acquire a database connection
    if ActiveRecord::Base.connection_pool.with_connection(&:active?)
      render plain: 'Application is OK'
    else
      render plain: 'Cannot connect to database!', status: :service_unavailable
    end
  end
end

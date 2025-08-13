# frozen_string_literal: true

# Controller for network monitoring to use to determine whether the
# application is running and the database is reachable.
class PingController < ApplicationController
  # Controller actions should be accessible without requiring authentication.
  skip_before_action :authenticate

  def verify
    # Check database connection
    ActiveRecord::Base.connection.execute('SELECT 1')
    render plain: 'Application is OK'
  rescue ActiveRecord::ConnectionNotEstablished => e
    Rails.logger.warn "Database connection failed: #{e.message}"
    render plain: 'Cannot connect to database!', status: :service_unavailable
  end
end

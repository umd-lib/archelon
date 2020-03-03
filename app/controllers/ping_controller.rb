# frozen_string_literal: true

# Controller for Icinga network monitoring to use to determine whether the
# application is running.
class PingController < ApplicationController
  # Controller actions should be accessible without requiring authenication.
  skip_before_action :authenticate

  def verify
    if ActiveRecord::Base.connected?
      render plain: 'Application is OK'
    else
      render plain: 'Cannot connect to database!', status: :service_unavailable
    end
  end
end

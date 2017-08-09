class ApplicationController < ActionController::Base
  include CasHelper
  before_action :authenticate

  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  layout 'blacklight'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Causes a "404 - Not Found" error page to be displayed.
  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
end

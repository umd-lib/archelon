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
    raise ActionController::RoutingError, 'Not Found'
  end

  def impersonating?
    session[:admin_id].present?
  end
  helper_method :impersonating?

  def impersonating_admin_id
    session[:admin_id]
  end
  helper_method :impersonating_admin_id

  def real_user
    return current_cas_user unless impersonating?
    CasUser.find(impersonating_admin_id)
  end
  helper_method :real_user

  def can_login_as?(user)
    current_cas_user.admin? && user.user? && (user.id != current_cas_user.id)
  end
  helper_method :can_login_as?

end

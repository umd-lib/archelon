class ApplicationController < ActionController::Base
  # UMD Customization
  include CasHelper

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  rescue_from CanCan::AccessDenied do
    render file: Rails.root.join('public', '403.html'), status: :forbidden, layout: false
  end

  before_action :authenticate
  # End UMD Customization

  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  layout :determine_layout if respond_to? :layout

  # UMD Customization
  # Causes a "404 - Not Found" error page to be displayed.
  def not_found
    render file: Rails.root.join('public', '404.html'), status: :not_found, layout: false
  end

  def forbidden
    render file: Rails.root.join('public', '403.html'), status: :forbidden, layout: false
  end

  def impersonating?
    session[:admin_id].present?
  end
  helper_method :impersonating?

  def impersonating_admin_id
    session[:admin_id]
  end
  helper_method :impersonating_admin_id

  def impersonating_admin
    CasUser.find(impersonating_admin_id)
  end
  helper_method :impersonating_admin

  def real_user
    return current_cas_user unless impersonating?

    impersonating_admin
  end
  helper_method :real_user

  def can_login_as?(user)
    current_cas_user.admin? && user.user? && (user.id != current_cas_user.id)
  end
  helper_method :can_login_as?
  # End UMD Customization
end

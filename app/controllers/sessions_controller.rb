# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :authenticate
  skip_before_action :verify_authenticity_token, only: [:create] if CasHelper.use_developer_login?

  def create # rubocop:disable Metrics/AbcSize
    @user = CasUser.find_or_create_from_auth_hash(request.env['omniauth.auth'])
    if @user.nil?
      session[:unauthorized_user] = true # Not sure if this is actually used anywhere
      CasAuthentication.sign_out(session, cookies)

      render(file: Rails.public_path.join('403.html'), status: :forbidden, layout: false) and return # rubocop:disable Style/AndOr, Layout/LineLength
    else
      sign_in(@user)
      redirect_to root_path
    end
  end

  def sign_in(user)
    CasAuthentication.sign_in(user.cas_directory_id, session, cookies)
  end

  def destroy
    CasAuthentication.sign_out(session, cookies)
    cas_logout_url = "#{CAS_URL}/logout"
    # UMD Blacklight 8 Fix
    redirect_to cas_logout_url, allow_other_host: true
    # End UMD Blacklight 8 Fix
  end

  def login_as # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Layout/LineLength
    user = CasUser.find(params[:user_id])
    if impersonating? && impersonating_admin_id == user.id
      sign_in(user)
      session.delete(:admin_id)
      redirect_to request.headers['HTTP_REFERER'] and return if request.headers['HTTP_REFERER'] # rubocop:disable Style/AndOr, Layout/LineLength
    elsif user && can_login_as?(user)
      session[:admin_id] = current_cas_user.id
      sign_in(user)
    else
      flash[:notice] = I18n.t('sessions.login_as.no_permission')
    end
    redirect_to root_path
  end
end

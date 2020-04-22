# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :authenticate

  def create
    @user = CasUser.find_or_create_from_auth_hash(request.env['omniauth.auth'])
    if @user.nil?
      session[:unauthorized_user] = true # Not sure if this is actually used anywhere
      CasAuthentication.sign_out(session, cookies)

      render(file: Rails.root.join('public', '403.html'), status: :forbidden, layout: false) and return # rubocop:disable Style/AndOr, Metrics/LineLength
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
    cas_logout_url = Rails.application.config.cas_url + '/logout'
    redirect_to cas_logout_url
  end

  def login_as # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/LineLength
    user = CasUser.find(params[:user_id])
    if impersonating? && impersonating_admin_id == user.id
      sign_in(user)
      session.delete(:admin_id)
      redirect_to request.headers['HTTP_REFERER'] and return if request.headers['HTTP_REFERER'] # rubocop:disable Style/AndOr, Metrics/LineLength
    elsif user && can_login_as?(user)
      session[:admin_id] = current_cas_user.id
      sign_in(user)
    else
      flash[:notice] = 'You do not have permission to access this page'
    end
    redirect_to root_path
  end
end

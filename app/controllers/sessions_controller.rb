# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :authenticate

  def create
    @user = CasUser.find_or_create_from_auth_hash(request.env['omniauth.auth'])
    if @user == nil
      session[:unauthorized_user] = true
      render(file: Rails.root.join('public', '403.html'), status: :forbidden, layout: false) and return
    else
      sign_in(@user)
      redirect_to root_path
    end
  end

  def sign_in(user)
    session[:cas_user] = user.cas_directory_id
  end

  def destroy
    session.delete(:cas_user)
    session.delete(:admin_id)
    cas_logout_url = Rails.application.config.cas_url + '/logout'
    redirect_to cas_logout_url
  end

  def login_as
    user = CasUser.find(params[:user_id])
    if impersonating? && impersonating_admin_id == user.id
      sign_in(user)
      session.delete(:admin_id)
      redirect_to request.headers['HTTP_REFERER'] and return if request.headers['HTTP_REFERER']
    else
      if user && can_login_as?(user)
        session[:admin_id] = current_cas_user.id
        sign_in(user)
      else
        flash[:notice] = 'You do not have permission to access this page'
      end
    end
    redirect_to root_path
  end
end

class SessionsController < ApplicationController
  skip_before_action :authenticate
  
  def create
    @user = CasUser.find_or_create_from_auth_hash(request.env["omniauth.auth"])
    if @user == nil
      session[:unauthorized_user] = true
      render(file: Rails.root.join('public', '403.html'), status: :forbidden, layout: false) and return 
    else
      session[:cas_user] = @user.cas_directory_id
      redirect_to root_path
    end
  end

  def destroy
    session[:cas_user] = nil
    session[:unauthorized_user] = nil
    cas_logout_url = Rails.application.config.cas_url + '/logout'
    redirect_to cas_logout_url
  end
end
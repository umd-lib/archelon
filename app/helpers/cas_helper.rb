# frozen_string_literal: true

module CasHelper
  def authenticate
    redirect_to login_path and return if !logged_in? && !request.env["omniauth.auth"]
    return if allow_access
    render(file: Rails.root.join('public', '403.html'), status: :forbidden, layout: false)
  end

  # Retrieves the User for the current request from the database, using the
  # "cas_user" id from the session, or nil if the User cannot be found.
  def current_cas_user
    CasUser.find_by(cas_directory_id: session[:cas_user])
  end

  def logged_in?
    session[:cas_user]
  end

  private

    # Returns true if entry is authorized, false otherwise.
    def allow_access
      !current_cas_user.nil? && !current_cas_user.unauthorized?
    end
end

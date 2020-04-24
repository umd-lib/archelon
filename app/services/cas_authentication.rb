# frozen_string_literal: true

# Encapsulates changes needed in login/logut
class CasAuthentication
  def self.sign_in(cas_directory_id, session, cookies)
    session[:cas_user] = cas_directory_id

    # Signed cookie is used for providing CAS directory id for Action Cable
    # authentication (see app/channels/application_cable/connection.rb)
    cookies.signed[:cas_user] = cas_directory_id
  end

  def self.sign_out(session, cookies)
    session.delete(:cas_user)
    session.delete(:admin_id)

    # Delete signed cookie used for Action Cable authentication
    cookies.delete(:cas_user)
  end
end

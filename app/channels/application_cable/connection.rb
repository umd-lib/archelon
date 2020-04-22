# frozen_string_literal: true

module ApplicationCable
  # Set ups Action Cable connection for authenticated users
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      find_verified_user
      self.current_user = find_verified_user
      logger.add_tags 'ActionCable', "CasUser id: #{current_user.id}"
    end

    protected

      def find_verified_user
        verified_user = CasUser.find_by(cas_directory_id: cookies.signed[:cas_user])

        return verified_user if verified_user

        reject_unauthorized_connection
      end
  end
end

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      # self.current_user = find_verified_user
      # logger.add_tags 'ActionCable', current_user.name
    end

    protected

      def find_verified_user
        # TODO Figure out how to actually do authentication
        puts "******* app/channels/application_cable/connection.rb"
        return true
        if (verified_user = CasUser.find_by(cas_directory_id: cookies.signed[:cas_user]))
          puts "******* app/channels/application_cable/connection.rb - find_verified_user: #{verified_user}"
          verified_user
        else
          reject_unauthorized_connection
        end
      end
  end
end

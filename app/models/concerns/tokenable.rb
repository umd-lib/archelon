# As suggested in https://stackoverflow.com/a/12109098
# Should be replaced by "has_secure_token" in Rails 5
module Tokenable
  extend ActiveSupport::Concern

  included do
    before_create :generate_token
  end

  protected

    def generate_token
      self.token = loop do
        random_token = SecureRandom.urlsafe_base64(nil, false)
        break random_token unless self.class.exists?(token: random_token)
      end
    end
end

# frozen_string_literal: true

# A user of the application
class CasUser < ApplicationRecord
  # Connects this user object to Blacklight's Bookmarks.
  include Blacklight::User

  enum user_type: { admin: 'admin', user: 'user', unauthorized: 'unauthorized' }
  validates :cas_directory_id, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true

  def self.find_or_create_from_auth_hash(auth)
    # update user info upon successful login, and return the user object
    where(cas_directory_id: auth[:uid]).first_or_initialize.tap do |user|
      user.cas_directory_id = auth[:uid]
      # only update from LDAP if we found anything
      if user.ldap_attributes
        user.name = user.ldap_attributes.name || user.cas_directory_id
        user.user_type = user.ldap_attributes.user_type
      end
      user.save!
    end
  end

  def ldap_attributes
    @ldap_attributes ||= LdapUserAttributes.create(cas_directory_id)
  end
end

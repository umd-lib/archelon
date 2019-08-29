# frozen_string_literal: true

# A user of the application
class CasUser < ApplicationRecord
  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User

  enum user_type: { admin: 'admin', user: 'user', unauthorized: 'unauthorized' }
  validates :cas_directory_id, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true

  def self.find_or_create_from_auth_hash(auth)
    ldap_user_attributes = LdapUserAttributes.create(auth[:uid])
    ldap_name = ldap_user_attributes.name
    ldap_user_type = ldap_user_attributes.user_type

    where(cas_directory_id: auth[:uid]).first_or_initialize.tap do |user|
      user.cas_directory_id = auth[:uid]
      update_name(user, ldap_name) unless user.name
      update_user_type(user, ldap_user_type)
      user.save!
    end
  end

  # The following methods are not intended to be called from outside this class.
  def self.update_name(user, name)
    return if !name && user.name

    user.name = user.cas_directory_id and return unless name # rubocop:disable Style/AndOr
    user.name = name
  end

  def self.update_user_type(user, user_type)
    return if !user_type && user.user_type

    user.user_type = :unauthorized
    return unless user_type

    user.user_type = user_type
  end
end

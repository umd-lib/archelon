# frozen_string_literal: true

# A user of the application
class CasUser < ApplicationRecord
  enum user_type: { admin: 'admin', user: 'user', unauthorized: 'unauthorized'}
  validates :cas_directory_id, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true

  def self.find_or_create_from_auth_hash(auth)
    ldap_attrs = ldap_attributes(auth[:uid])
    where(cas_directory_id: auth[:uid]).first_or_initialize.tap do |user|
      user.cas_directory_id = auth[:uid]
      update_name(user, ldap_attrs) unless user.name
      update_user_type(user, ldap_attrs)
			user.save!
		end
  end

  private
    def self.update_name(user, ldap_attrs)
      name = ldap_attrs_value(ldap_attrs, :name)
      return if !name && user.name
      user.name = user.cas_directory_id and return if !name
      user.name = name
    end

    def self.update_user_type(user, ldap_attrs)
      groups = ldap_attrs_value(ldap_attrs, :groups)
      return if !groups && user.user_type
      user.user_type = :unauthorized
      return if !groups
      user.user_type = :user if groups.include?(GROUPER_USER_GROUP)
      user.user_type = :admin if groups.include?(GROUPER_ADMIN_GROUP)
    end

    def self.ldap_attrs_value(result, key)
      return result[key] if result && result.key?(key)
    end

    def self.ldap_attributes(uid)
      filter = Net::LDAP::Filter.eq( 'uid', uid)
      first_entry = LDAP.search(:base => LDAP_BASE, :filter => filter, :attributes => LDAP_ATTRIBUTES).first
      return {
        name: first_entry[LDAP_NAME_ATTR].first,
        groups: first_entry[LDAP_GROUPS_ATTR]
      } if first_entry
    end

end

# frozen_string_literal: true

# A user of the application
class CasUser < ApplicationRecord
  # Connects this user object to Blacklight's Bookmarks.
  include Blacklight::User

  has_and_belongs_to_many :groups # rubocop:disable Rails/HasAndBelongsToMany
  has_many :public_keys, dependent: :destroy

  enum user_type: { admin: 'admin', user: 'user', unauthorized: 'unauthorized' }
  validates :cas_directory_id, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true

  def self.find_or_create_from_auth_hash(auth)
    # update user info upon successful login, and return the user object
    where(cas_directory_id: auth[:uid]).first_or_initialize.tap do |user|
      user.cas_directory_id = auth[:uid]
      user.update_from_ldap
      user.save!
    end
  end

  def ldap_attributes
    @ldap_attributes ||= LdapUserAttributes.create(cas_directory_id)
  end

  def update_from_ldap
    # only update from LDAP if we found anything
    return unless ldap_attributes

    self.name = ldap_attributes.name || cas_directory_id
    self.user_type = ldap_attributes.user_type
    self.groups = ldap_attributes.groups.map { |dn| Group.from_dn(dn) }.reject(&:nil?)
  end

  def in_group?(group_name)
    groups.map(&:name).include? group_name.to_s
  end
end

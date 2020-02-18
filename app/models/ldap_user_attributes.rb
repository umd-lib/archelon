# frozen_string_literal: true

# Retrieves user attributes from LDAP
class LdapUserAttributes
  attr_reader :name, :user_type

  private_class_method :new

  def initialize(name, user_type)
    @name = name
    @user_type = user_type
  end

  # Constructs a new instance from the CAS directory id,
  # using LDAP.
  #
  # This method requires an LDAP server connection unless an LDAP_OVERRIDE
  # is set in the development environment.
  #
  # @param cas_directory_id the CAS directory id for the user.
  # @return the LdapUserAttributes object
  def self.create(cas_directory_id)
    @cas_directory_id = cas_directory_id

    # Possible skip LDAP search (intended to only work in development environment)
    return new(cas_directory_id, LDAP_OVERRIDE) if ldap_override?

    filter = Net::LDAP::Filter.eq('uid', cas_directory_id)
    first_entry = LDAP.search(base: LDAP_BASE, filter: filter, attributes: LDAP_ATTRIBUTES)&.first
    return unless first_entry

    name = first_entry[LDAP_NAME_ATTR].first
    groups = first_entry[LDAP_GROUPS_ATTR]
    user_type = user_type_from_groups(groups)
    new(name, user_type)
  end

  # Returns true if the LDAP search should be skipped
  def self.ldap_override?
    Rails.env.development? && LDAP_OVERRIDE.present?
  end

  # Returns a user type, based on the given list of Grouper groups
  #
  # @param groups [Array<String>] the Grouper groups the user is a member of
  # @return the user type of the user. See CasUser.user_type enumeration
  def self.user_type_from_groups(groups)
    if groups
      return :admin if groups.include?(GROUPER_ADMIN_GROUP)
      return :user if groups.include?(GROUPER_USER_GROUP)
    end
    :unauthorized
  end
end

# frozen_string_literal: true

# Retrieves user attributes from LDAP
class LdapUserAttributes
  attr_reader :name, :groups

  def initialize(name, groups)
    @name = name
    @groups = groups
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
    return new(cas_directory_id, LDAP_OVERRIDE.split(' ')) if ldap_override?

    filter = Net::LDAP::Filter.eq('uid', cas_directory_id)
    first_entry = LDAP.search(base: LDAP_BASE, filter: filter, attributes: LDAP_ATTRIBUTES)&.first
    return unless first_entry

    name = first_entry[LDAP_NAME_ATTR].first
    groups = first_entry[LDAP_GROUPS_ATTR]
    new(name, groups)
  end

  # Returns true if the LDAP search should be skipped
  def self.ldap_override?
    Rails.env.development? && LDAP_OVERRIDE.present?
  end

  def self.user_type_from_groups(groups)
    if groups
      groups_lc = groups.map(&:downcase)
      return :admin if groups_lc.include? GROUPER_GROUPS['Administrators'].downcase
      return :user if groups_lc.include? GROUPER_GROUPS['Users'].downcase
    end
    :unauthorized
  end

  # Returns a user type, based on list of Grouper groups
  #
  # @return the user type of the user. See CasUser.user_type enumeration
  def user_type
    self.class.user_type_from_groups(@groups)
  end
end

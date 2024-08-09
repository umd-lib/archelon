# frozen_string_literal: true

# User group
class Group < ApplicationRecord
  # the LDAP server returns some group DNs in all lowercase
  NAME_MAPPING = GROUPER_GROUPS.invert.transform_keys(&:downcase)

  has_and_belongs_to_many :cas_users # rubocop:disable Rails/HasAndBelongsToMany

  def self.from_dn(ldap_dn)
    return unless NAME_MAPPING.key? ldap_dn.downcase

    find_or_create_by name: NAME_MAPPING[ldap_dn.downcase]
  end
end

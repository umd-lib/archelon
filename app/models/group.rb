# frozen_string_literal: true

# User group
class Group < ApplicationRecord
  NAME_MAPPING = GROUPER_GROUPS.invert

  has_and_belongs_to_many :cas_users # rubocop:disable Rails/HasAndBelongsToMany

  def self.from_dn(ldap_dn)
    return unless NAME_MAPPING.key? ldap_dn

    find_or_create_by name: NAME_MAPPING[ldap_dn]
  end
end

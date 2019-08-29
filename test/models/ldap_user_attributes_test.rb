# frozen_string_literal: true

require 'test_helper'

class LdapUserAttributesTest < ActiveSupport::TestCase
  test 'Grouper groups to user type conversion' do
    assert_equal :unauthorized, LdapUserAttributes.user_type_from_groups(nil)
    assert_equal :unauthorized, LdapUserAttributes.user_type_from_groups([])
    assert_equal :unauthorized, LdapUserAttributes.user_type_from_groups(['SOME_OTHER_GROUP'])

    assert_equal :user, LdapUserAttributes.user_type_from_groups([GROUPER_USER_GROUP])
    assert_equal :user, LdapUserAttributes.user_type_from_groups(['SOME_OTHER_GROUP', GROUPER_USER_GROUP])
    assert_equal :user, LdapUserAttributes.user_type_from_groups([GROUPER_USER_GROUP, 'SOME_OTHER_GROUP'])

    assert_equal :admin, LdapUserAttributes.user_type_from_groups([GROUPER_ADMIN_GROUP])
    assert_equal :admin, LdapUserAttributes.user_type_from_groups([GROUPER_ADMIN_GROUP, 'SOME_OTHER_GROUP'])
    assert_equal :admin, LdapUserAttributes.user_type_from_groups(['SOME_OTHER_GROUP', GROUPER_ADMIN_GROUP])
    assert_equal :admin, LdapUserAttributes.user_type_from_groups([GROUPER_ADMIN_GROUP, GROUPER_USER_GROUP])
    assert_equal :admin, LdapUserAttributes.user_type_from_groups([GROUPER_USER_GROUP, GROUPER_ADMIN_GROUP])
    assert_equal :admin, LdapUserAttributes.user_type_from_groups(
      ['SOME_OTHER_GROUP', GROUPER_USER_GROUP, GROUPER_ADMIN_GROUP]
    )
    assert_equal :admin, LdapUserAttributes.user_type_from_groups(
      [GROUPER_USER_GROUP, GROUPER_ADMIN_GROUP, 'SOME_OTHER_GROUP']
    )
  end

  test 'Creation from LDAP with valid result' do
    ldap_entry = Net::LDAP::Entry.new
    ldap_entry[LDAP_NAME_ATTR] = Faker::Name.name
    ldap_entry[LDAP_GROUPS_ATTR] = [GROUPER_USER_GROUP, GROUPER_ADMIN_GROUP]

    LDAP.stub :search, [ldap_entry] do
      ldap_user_attributes = LdapUserAttributes.create('foo')
      assert_equal :admin, ldap_user_attributes.user_type
    end
  end

  test 'Creation from LDAP with nil result' do
    LDAP.stub :search, nil do
      ldap_user_attributes = LdapUserAttributes.create('foo')
      assert_nil ldap_user_attributes
    end
  end

  test 'Creation from LDAP with empty result' do
    LDAP.stub :search, [] do
      ldap_user_attributes = LdapUserAttributes.create('foo')
      assert_nil ldap_user_attributes
    end
  end

  test 'Creation from LDAP with missing attributes' do
    ldap_entry = Net::LDAP::Entry.new
    ldap_entry['unexpected_attribute1'] = Faker::Name.name
    ldap_entry['unexpected_attribute2'] = [GROUPER_USER_GROUP, GROUPER_ADMIN_GROUP]

    LDAP.stub :search, [ldap_entry] do
      ldap_user_attributes = LdapUserAttributes.create('foo')
      assert_nil ldap_user_attributes.name
      assert_equal :unauthorized, ldap_user_attributes.user_type
    end
  end
end

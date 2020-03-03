# frozen_string_literal: true

require 'test_helper'

class LdapUserAttributesTest < ActiveSupport::TestCase
  test 'Grouper groups to user type conversion' do
    assert_equal :unauthorized, LdapUserAttributes.user_type_from_groups(nil)
    assert_equal :unauthorized, LdapUserAttributes.user_type_from_groups([])
    assert_equal :unauthorized, LdapUserAttributes.user_type_from_groups(['SOME_OTHER_GROUP'])

    assert_equal :user, LdapUserAttributes.user_type_from_groups([GROUPER_GROUPS['Users']])
    assert_equal :user, LdapUserAttributes.user_type_from_groups(['SOME_OTHER_GROUP', GROUPER_GROUPS['Users']])
    assert_equal :user, LdapUserAttributes.user_type_from_groups([GROUPER_GROUPS['Users'], 'SOME_OTHER_GROUP'])

    assert_equal :admin, LdapUserAttributes.user_type_from_groups([GROUPER_GROUPS['Administrators']])
    assert_equal :admin, LdapUserAttributes.user_type_from_groups(
      [GROUPER_GROUPS['Administrators'], 'SOME_OTHER_GROUP']
    )
    assert_equal :admin, LdapUserAttributes.user_type_from_groups(
      ['SOME_OTHER_GROUP', GROUPER_GROUPS['Administrators']]
    )
    assert_equal :admin, LdapUserAttributes.user_type_from_groups(
      [GROUPER_GROUPS['Administrators'], GROUPER_GROUPS['Users']]
    )
    assert_equal :admin, LdapUserAttributes.user_type_from_groups(
      [GROUPER_GROUPS['Users'], GROUPER_GROUPS['Administrators']]
    )
    assert_equal :admin, LdapUserAttributes.user_type_from_groups(
      ['SOME_OTHER_GROUP', GROUPER_GROUPS['Users'], GROUPER_GROUPS['Administrators']]
    )
    assert_equal :admin, LdapUserAttributes.user_type_from_groups(
      [GROUPER_GROUPS['Users'], GROUPER_GROUPS['Administrators'], 'SOME_OTHER_GROUP']
    )
  end

  test 'Ignore group name case when assigning user type' do
    assert_equal :user, LdapUserAttributes.user_type_from_groups([GROUPER_USER_GROUP.downcase])
    assert_equal :admin, LdapUserAttributes.user_type_from_groups([GROUPER_ADMIN_GROUP.downcase])
  end

  test 'Creation from LDAP with valid result' do
    ldap_entry = Net::LDAP::Entry.new
    ldap_entry[LDAP_NAME_ATTR] = Faker::Name.name
    ldap_entry[LDAP_GROUPS_ATTR] = [GROUPER_GROUPS['Users'], GROUPER_GROUPS['Administrators']]

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
    ldap_entry['unexpected_attribute2'] = [GROUPER_GROUPS['Users'], GROUPER_GROUPS['Administrators']]

    LDAP.stub :search, [ldap_entry] do
      ldap_user_attributes = LdapUserAttributes.create('foo')
      assert_nil ldap_user_attributes.name
      assert_equal :unauthorized, ldap_user_attributes.user_type
    end
  end

  test 'LDAP_OVERRIDE should set the user_type value and LDAP is not searched' do
    Rails.env = 'development'
    stub_const('LDAP_OVERRIDE', 'user')

    ldap_user_attributes = LdapUserAttributes.create('foo')
    assert 'foo', ldap_user_attributes.name
    assert 'user', ldap_user_attributes.user_type
    expect(LDAP).not_to receive(:search)

    stub_const('LDAP_OVERRIDE', 'barbaz')
    ldap_user_attributes = LdapUserAttributes.create('foo')
    assert 'foo', ldap_user_attributes.name
    assert 'barbaz', ldap_user_attributes.user_type
    expect(LDAP).not_to receive(:search)
  end

  test 'ldap_override? should only work in Rails development environment' do
    stub_const('LDAP_OVERRIDE', 'user')

    assert_not_equal 'development', Rails.env
    assert_not LdapUserAttributes.ldap_override?

    Rails.env = 'development'
    assert_equal 'development', Rails.env
    assert LdapUserAttributes.ldap_override?

    Rails.env = 'production'
    assert_equal 'production', Rails.env
    assert_not LdapUserAttributes.ldap_override?
  end

  test 'ldap_override? should only work with LDAP_OVERRIDE containing a non-nil and non-blank value' do
    Rails.env = 'development'
    assert_equal 'development', Rails.env

    stub_const('LDAP_OVERRIDE', 'user')
    assert LdapUserAttributes.ldap_override?

    stub_const('LDAP_OVERRIDE', nil)
    assert_not LdapUserAttributes.ldap_override?

    stub_const('LDAP_OVERRIDE', '')
    assert_not LdapUserAttributes.ldap_override?

    stub_const('LDAP_OVERRIDE', '   ')
    assert_not LdapUserAttributes.ldap_override?
  end

  def teardown
    # Ensure that is reset Rails.env to 'test'
    Rails.env = 'test'
  end
end

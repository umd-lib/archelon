# config/initializers/ldap.rb

# Load the configuration
LDAP_CONFIG = Archelon::Application.config_for :ldap

# LDAP and Grouper Constants from configuration
LDAP_NAME_ATTR = LDAP_CONFIG['name_attr']
LDAP_GROUPS_ATTR = LDAP_CONFIG['groups_attr']
LDAP_ATTRIBUTES = [LDAP_NAME_ATTR,LDAP_GROUPS_ATTR]
LDAP_BASE = LDAP_CONFIG['base']
GROUPER_GROUPS = LDAP_CONFIG['grouper_groups']
LDAP_OVERRIDE = LDAP_CONFIG['ldap_override']

# Initialize LDAP object
LDAP = Net::LDAP.new(encryption: :simple_tls)
LDAP.host = LDAP_CONFIG['host']
LDAP.port = LDAP_CONFIG['port']
LDAP.auth LDAP_CONFIG['bind_dn'], LDAP_CONFIG['bind_password']

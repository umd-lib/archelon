# config/initializers/ldap.rb

# Load the configuration
template = ERB.new File.new("#{Rails.root}/config/ldap.yml").read
LDAP_CONFIG = YAML.load(template.result(binding))[Rails.env]

# LDAP and Grouper Constants from configuration
LDAP_NAME_ATTR = LDAP_CONFIG['name_attr']
LDAP_GROUPS_ATTR = LDAP_CONFIG['groups_attr']
LDAP_ATTRIBUTES = [LDAP_NAME_ATTR,LDAP_GROUPS_ATTR]
LDAP_BASE = LDAP_CONFIG['base']
GROUPER_ADMIN_GROUP = LDAP_CONFIG['grouper_admin_group']
GROUPER_USER_GROUP = LDAP_CONFIG['grouper_user_group']

# Initialize LDAP object
LDAP = Net::LDAP.new(encryption: :simple_tls)
LDAP.host = LDAP_CONFIG['host']
LDAP.port = LDAP_CONFIG['port']
LDAP.auth LDAP_CONFIG['bind_dn'], LDAP_CONFIG['bind_password']

 #!/bin/bash

# plastron needs to own the children of /data,
# so it can SFTP things in and out of here
mkdir -p /data/imports
mkdir -p /data/exports
chown plastron:plastron /data/*

cat >>/etc/ssh/sshd_config <<END
# configuration to allow the plastron user to SFTP files
# in and out of Archelon's "dropbox" using public keys
# stored in the Archelon Rails database
AuthorizedKeysCommand /etc/archelon/get-plastron-authorized-keys.sh
AuthorizedKeysCommandUser nobody

END

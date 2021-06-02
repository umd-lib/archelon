#!/bin/bash

# this script is for use with the AuthorizedKeysCommand in sshd_config

# if the connecting user is plastron, retrieve the list of public SSH
# keys for Archelon users
if [ "$1" == "plastron" ]; then
    curl -sf "http://localhost:3000/public_keys"
fi

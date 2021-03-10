#!/bin/bash

# Start the SSH daemon for SFTP
service ssh start

# Start Archelon
bin/archelon.sh

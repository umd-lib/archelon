#!/bin/bash

# Start the SSH daemon for SFTP
service ssh start

# wait for the database to be up
echo -n Checking database host/port...
until nc -z archelon-db 5432; do
  echo -n .
  sleep 1
done
echo Done

# Start Archelon
exec bin/archelon.sh

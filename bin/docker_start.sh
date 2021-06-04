#!/bin/bash

# Start the SSH daemon for SFTP
service ssh start

# wait for the database to be up
echo -n Checking database host/port...

# Set DATABASE_HOST to ARCHELON_DATABASE_HOST or a default ("archelon-db")
DATABASE_HOST="${ARCHELON_DATABASE_HOST:-archelon-db}"

until nc -z $DATABASE_HOST 5432; do
  echo -n .
  sleep 1
done
echo Done

# Start Archelon
exec bin/archelon.sh

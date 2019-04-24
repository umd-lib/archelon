#!/usr/bin/env bash

bundle exec rake db:migrate

exec bundle exec rails server --binding 0.0.0.0

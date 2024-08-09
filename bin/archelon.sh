#!/usr/bin/env bash

bundle exec rails db:migrate
bundle exec rails db:seed

exec bundle exec rails server --binding 0.0.0.0

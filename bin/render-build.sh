#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install --no-deployment
bundle exec rake assets:precompile
bundle exec rake assets:clean
bundle exec rake db:migrate
bundle exec rails db:seed
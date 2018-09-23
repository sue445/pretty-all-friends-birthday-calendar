#!/bin/bash -xe

bundle check --path=vendor/bundle || bundle install --path=vendor/bundle --jobs=4 --retry=3
bundle clean

# Resolve bundler version difference between Gemfile.lock and pre-installed in CI
gem install restore_bundled_with --no-document
restore-bundled-with

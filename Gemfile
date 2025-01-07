# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gem "hashie"
gem "icalendar"
gem "rake", require: false

# FIXME: Remove followings after icalendar v2.10.4+ is published ref. https://github.com/icalendar/icalendar/pull/304
gem "base64"
gem "logger"

group :test do
  gem "rspec"
  gem "rspec-temp_dir"
end

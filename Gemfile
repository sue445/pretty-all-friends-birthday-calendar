# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gem "hashie"

# FIXME: Workaround for Ruby 3.4 ref. https://github.com/icalendar/icalendar/pull/304
# gem "icalendar"
gem "icalendar", github: "sue445/icalendar", branch: "ruby_3.4"

gem "rake", require: false

group :test do
  gem "rspec"
  gem "rspec-temp_dir"
end

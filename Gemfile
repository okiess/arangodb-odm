source "https://rubygems.org"

gem 'httparty', '>= 0.21.0'
gem 'json'

# Pin transitive dependency to the patched release to fix
# CVE-2026-126080 (DoS in safe_constantize) and CVE-2026-126075 (XSS in
# MessagePack serializer); fixed in activesupport 8.1.4.1.
gem 'activesupport', '~> 8.1.4.1'

group :development do
  gem "shoulda", ">= 0"
  gem "bundler", ">= 2.0"
  gem "rake", ">= 12.3.3"
  gem "git", ">= 1.11.0"
  gem "test-unit", "~> 3.7"
end

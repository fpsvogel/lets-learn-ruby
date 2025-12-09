source "https://rubygems.org"

####
# Welcome to your project's Gemfile, used by Rubygems & Bundler.
#
# To install a plugin, run:
#
#   bundle add new-plugin-name -g bridgetown_plugins
#
# This will ensure the plugin is added to the correct Bundler group.
#
# When you run Bridgetown commands, we recommend using a binstub like so:
#
#   bin/bridgetown start (or console, etc.)
#
# This will help ensure the proper Bridgetown version is running.
####

# If you need to upgrade/switch Bridgetown versions, change the line below
# and then run `bundle update bridgetown`
source "https://gems.bridgetownrb.com" do
  gem "bridgetown", "~> 2.1.0.beta1"
  gem "bridgetown-seo-tag"
end
gem "puma"
gem "kramdown"
gem "nokogiri"
gem "debug"

group :test, optional: true do
  gem "minitest"
  gem "minitest-reporters"
  gem "rails-dom-testing"
  gem "pretty-diffs"
end

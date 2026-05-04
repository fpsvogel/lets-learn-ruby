source "https://rubygems.org"

gem "bridgetown", github: "bridgetownrb/bridgetown", branch: "refactor-start"
gem "puma"
gem "rackup" # ? missing from https://github.com/bridgetownrb/bridgetown/blob/39050274509cb7f731ec9b87527f97ac46403f59/bridgetown-core/lib/bridgetown-core.rb#L36-L45
source "https://gems.bridgetownrb.com" do
  gem "bridgetown-seo-tag"
end

gem "kramdown"
gem "nokogiri"

group :test, optional: true do
  gem "minitest"
  gem "minitest-reporters"
  gem "rails-dom-testing"
  gem "pretty-diffs"
end

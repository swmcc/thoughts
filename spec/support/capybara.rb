require "capybara/rspec"

Capybara.default_driver = :selenium_headless
Capybara.javascript_driver = :selenium_headless

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :selenium_headless
  end
end

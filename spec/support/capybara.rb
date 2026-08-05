require "capybara/rspec"

# Headless Chrome rather than headless Firefox: Chrome is what Rails uses by
# default for system tests, and it is the browser available on our machines.
# Override with CAPYBARA_DRIVER if you need a different one.
CAPYBARA_DRIVER = ENV.fetch("CAPYBARA_DRIVER", "selenium_chrome_headless").to_sym

if CAPYBARA_DRIVER.to_s.include?("chrome")
  # Let Selenium Manager supply a chromedriver matching the installed Chrome
  # instead of trusting whatever is on PATH: a stale system-wide chromedriver
  # (e.g. one a package manager installed years ago) otherwise wins and every
  # system spec dies with SessionNotCreatedError.
  #
  # Resolved once per process because each example builds a new Service, and
  # shelling out to Selenium Manager every time makes the suite crawl.
  # --avoid-stats skips its usage-telemetry call, which can stall for minutes.
  Selenium::WebDriver::Chrome::Service.driver_path =
    Selenium::WebDriver::SeleniumManager
      .binary_paths("--browser", "chrome", "--skip-driver-in-path", "--avoid-stats")
      .fetch("driver_path")
end

Capybara.default_driver = CAPYBARA_DRIVER
Capybara.javascript_driver = CAPYBARA_DRIVER

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by CAPYBARA_DRIVER
    # Deterministic desktop viewport. Headless Chrome defaults to ~756px wide,
    # which is below Tailwind's `lg` breakpoint (1024px) — the timeline sidebar
    # (and its tag links) are hidden there, so specs click different elements
    # depending on window size. Pin it above the breakpoint.
    if CAPYBARA_DRIVER.to_s.include?("chrome")
      page.driver.browser.manage.window.resize_to(1400, 1000)
    end
  end
end

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

# Chrome 158 rejects the wildcard origin Capybara 3.40 passes to
# Storage.clearDataForOrigin in ChromeDriver#reset!, so every system spec
# errors during teardown ("* is not a valid URL"). Do the same cleanup by
# hand: wipe the page's web storage while still on the app's origin, then
# cookies for all origins. Drop this once Capybara ships a fix.
module ChromeWildcardStorageResetFix
  def reset!
    clear_app_web_storage
    super
  rescue Selenium::WebDriver::Error::InvalidArgumentError => e
    raise unless e.message.include?("is not a valid URL")

    execute_cdp("Network.clearBrowserCookies")
  end

  private

  def clear_app_web_storage
    execute_script("localStorage.clear(); sessionStorage.clear();") if current_url.to_s.start_with?("http")
  rescue Selenium::WebDriver::Error::WebDriverError
    # No page or an open alert: super handles both.
  end
end

Capybara::Selenium::Driver::ChromeDriver.prepend(ChromeWildcardStorageResetFix)

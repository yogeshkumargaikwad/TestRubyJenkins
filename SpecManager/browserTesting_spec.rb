require 'selenium-webdriver'
require 'yaml'
require 'saucelabs'
require 'rspec'
include SauceLabs
describe "test" do
  it "test1" do
      #ENV['BROWSER'] = :browser
      #browser = SauceLabs.watir_browser
      browser = SauceLabs.selenium_driver(browser = 'chrome35|windows8', browser_options = {})
      #browser.goto "http://www.google.com"
      #browser.quit
      # SauceLabs.selenium_driver(browser = :'chrome35|windows8', browser_options = {:url => 'http://localhost:4444/wd/hub'})
      browser = SauceLabs.selenium_driver()
      browser.get "http://www.google.com"
      browser.close
    end
end


require "selenium-webdriver"
require "rspec"
describe "Google Search" do
  before(:each) do
    Selenium::WebDriver::Chrome.driver_path = "/home/qa/Browsers/chromedriver";
    puts Selenium::WebDriver::Chrome.driver_path.to_s()
    @driver = Selenium::WebDriver.for(:chrome)
    @base_url = "https://www.google.co.in/"
    @driver.get @base_url
    @driver.manage.timeouts.implicit_wait = 5000
  end

  after(:each) do
    @driver.quit
  end

  it "search text on google" do
    puts 'In It'
    @driver.get(@base_url + "/")
    @driver.find_element(:id, "lst-ib").clear
    @driver.find_element(:id, "lst-ib").send_keys "testing"
    @driver.find_element(:id, "lst-ib").click
    @driver.manage.timeouts.implicit_wait = 10000
  end
end


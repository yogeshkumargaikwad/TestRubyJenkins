require "selenium-webdriver"
require "rspec"
describe "Google Search" do

  before(:each) do
    puts 'In Google Search Page Spec Before'
    puts ENV['JENKINS_HOME']+"/chromedriver.exe"    
    Selenium::WebDriver::Chrome.driver_path = ENV['JENKINS_HOME']+"/chromedriver.exe";
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
    @driver.get(@base_url + "/")
    @driver.find_element(:id, "lst-ib").clear
    @driver.find_element(:id, "lst-ib").send_keys "testing"
    @driver.find_element(:id, "lst-ib").click
  end

end

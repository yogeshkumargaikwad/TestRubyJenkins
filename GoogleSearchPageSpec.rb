require "selenium-webdriver"
require "rspec"
describe "Google Search" do

  before(:each) do
    Selenium::WebDriver::Firefox.driver_path = "#{ENV['BROWSER']}/geckodriver.exe";
    puts Selenium::WebDriver::Firefox.driver_path.to_s()
    #@driver = Selenium::WebDriver.for(:chrome)
	  @driver = Selenium::WebDriver.for(:firefox)
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


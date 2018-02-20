#Created By : Monika Pingale
#Created Date : 21/12/2017
#Modified date :
require_relative '../../src/pageObjects/RestApiTester'
require "selenium-webdriver"
require "rspec"
describe RestAPITester do
	before(:all){
		@driver = Selenium::WebDriver.for :firefox
		@objRestAPITester = RestAPITester.new(@driver)
	}
	it "should check correct page" do
		expect(@objRestAPITester.getDriver.title).to eq "REST API Tester"
	end
	it "select a service url" do
		@objRestAPITester.selectServiceUrl("/services/apexrest/InboundLead")
	end
	it "select a method type" do
		@objRestAPITester.selectMethodType("post")
	end
	it "should insert lead" do
		@objRestAPITester.callInbound
		expect(@objRestAPITester.recordInserted?).to be true
	end
	it "should check lead owner" do 
		expect(@objRestAPITester.leadAssignedTo?("Vidu Mangrulkar")).to be true
	end
	it "should check journey creation" do 
		expect(@objRestAPITester.journeysCreated? > 0).to be true
	end
	it "should check activity creation" do 
		expect(@objRestAPITester.activitiesCreated? > 0).to be true
	end
	it "should check activity creation for duplicate lead insertion" do
		@objRestAPITester.callInbound
		expect(@objRestAPITester.activitiesCreated? > 1).to be true
		expect(@objRestAPITester.journeysCreated?).to eql 1
	end
	after(:all){
		@driver.quit
	}
end
#Created By : Monika Pingale
#Created Date : 21/12/2017
#Modified date :
require 'enziUIUtility'
require 'salesforce'
require 'selenium-webdriver'
require 'yaml'
require 'json'
class RestAPITester
	@driver = nil
	@records = nil
	@recordsInJson = nil
	def initialize(driver) 
		@driver = driver
		file = File.open("../testData/credentials.yaml", "r")
		mapCredentials = YAML.load(file.read())
		recordFile = File.open("E:/Projects/Rspec Assignment/SF-QA-Automation-amol/src/testData/records.json", "r")
		@recordsInJson = recordFile.read()
		@records = JSON.parse(@recordsInJson)
		@driver.get "https://test.salesforce.com/login.jsp?pw=#{mapCredentials['password']}&un=#{mapCredentials['username']}"
		@salesforceBulk = Salesforce.login(mapCredentials['username'],mapCredentials['password'],true)
		EnziUIUtility.wait(driver,:id,"tsid",10)
		url = driver.current_url();
    	newUrl = url.split('/home')
    	@driver.get "#{newUrl[0]}"+"/apex/#{RestAPITester}"
	end
	def getDriver
		@driver
	end
	def selectServiceUrl(serviceUrl)
		EnziUIUtility.selectOption(@driver,:id,'service-url-id',"#{serviceUrl}")
	end
	def selectMethodType(methodName)
		EnziUIUtility.selectOption(@driver,:id,'method-type-id',"#{methodName}")
		#lastName =  @driver.find_element(:xpath,"//*[@id='payload-json']/ul/li/ul/li[1]")
		#EnziUIUtility.clickElement(@driver,:xpath,"//div[@id='active2']/ul/li[2]/a")

	end
	def callInbound
		EnziUIUtility.selectChildByText(@driver,:id,'active2','Raw Text')
		wait = Selenium::WebDriver::Wait.new(:timeout => 10);
		wait.until { @driver.find_element(:id,"payload-row").displayed? }
		if @driver.find_element(:id,"payload-row").displayed? then
			@driver.find_element(:id,"payload-row").clear 
			wait.until { @driver.find_element(:id,"payload-row").displayed? }	
			EnziUIUtility.setValue(@driver,:id,"payload-row","#{@recordsInJson}")
			sleep(10)	
			EnziUIUtility.clickElement(@driver,:id,"send-button-id")
		end
		sleep(10)
	end
	def recordInserted?
		createdLead = Salesforce.getRecords(@salesforceBulk,"Lead","SELECT id FROM Lead WHERE Email = '#{@records['body']['email']}'")
		if createdLead.result.records[0] != nil then
			@createdLeadId = createdLead.result.records[0].fetch("Id")
			return true
		else
			return false
		end
	end
	def leadAssignedTo?(ownerName)
		ownerId = Salesforce.getRecords(@salesforceBulk,"User","SELECT id FROM User WHERE Name = 'Vidu Mangrulkar'").result.records[0].fetch("Id")
		createdLeadOwner = Salesforce.getRecords(@salesforceBulk,"Lead","SELECT l.Owner.id FROM Lead l WHERE Email = 'monika.pingale@example.com'").result.records[0].fetch("Owner.Id")
		createdLeadOwner.eql?("#{ownerId}")
	end
	def journeysCreated?
		count = 0
  		createdJourneyId = Salesforce.getRecords(@salesforceBulk,"Journey__c","SELECT Id FROM Journey__c WHERE email__c = '#{@records['body']['email']}'")
  		if createdJourneyId.result.records[0] != nil then
  			createdJourneyId.result.records.each{ count = count+1 }
  			return count
  		else
    		return count
    	end
  	end
  	def activitiesCreated?
  		count = 0
  		createdTasksIds = Salesforce.getRecords(@salesforceBulk,"Task","SELECT Id FROM Task WHERE WhoId = '#{@createdLeadId}'") 
  		if createdTasksIds.result.records[0] != nil then
  			createdTasksIds.result.records.each{ count = count + 1 ; puts "#{count}"}
  			return count
  		else
    		return count
    	end
  	end
end

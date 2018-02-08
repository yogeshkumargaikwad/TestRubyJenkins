#Created By : Monika Pingale
#Created Date : 28/12/2017
#Modified date :
require 'enziUIUtility'
require 'salesforce'
require 'selenium-webdriver'
require 'yaml'
require 'json'
require 'date'
class ManageTours
	@driver = nil
	@records = nil
	@recordsInJson = nil
	@recordInsertedIds = nil
	def initialize(driver) 
		@driver = driver
		@recordInsertedIds = Hash.new
		recordFile = File.open("E:/Projects/Training/ROR/ManageTour Page/Src/testData/records.json", "r")
		recordsInJson = recordFile.read()
		@records = JSON.parse(recordsInJson)
		file = File.open("E:/Projects/Training/ROR/ManageTour Page/Src/testData/credentials.yaml", "r")
		mapCredentials = YAML.load(file.read())
		@driver.get "https://test.salesforce.com/login.jsp?pw=#{mapCredentials['password']}&un=#{mapCredentials['username']}"
		@salesforceBulk = Salesforce.login(mapCredentials['username'],mapCredentials['password'],true)
		EnziUIUtility.wait(driver,:id,"tsid",10000)
	end
	def insertTestData(dataToInsert,objectType)
		@recordInsertedIds["#{objectType}"] = Salesforce.createRecords(@salesforceBulk,objectType,dataToInsert)
		puts @recordInsertedIds
	end
	def openPageFor(objectRecordId)
		url = @driver.current_url();
		newUrl = url.split('/home')
    	@driver.get "#{newUrl[0]}"+"/#{objectRecordId}"
    	EnziUIUtility.wait(@driver,:name,"manage_tours",10)
    	btn = @driver.find_element(:name,"manage_tours")
    	btn.click
    	newWindow = @driver.current_url();
    	EnziUIUtility.switchToWindow(@driver,newWindow)
    	EnziUIUtility.wait(@driver,:id,"numberofDesks",100)
	end
	def insertTour
    	EnziUIUtility.wait(@driver,:id,"numberofDesks",10)
    	EnziUIUtility.setValue(@driver,:id,"numberofDesks","#{@records[1]['tour'][0]['numberOfDesks']}")
    	EnziUIUtility.setValue(@driver,:id,"companySize","#{@records[1]['tour'][0]['companySize']}")
    	elementTocheck1 =  @driver.find_elements(:id,"inputContact")
    	elementTocheck2 =  @driver.find_elements(:id,"inputOpportunity")
    	if !elementTocheck1.empty? then
    		inputContact = EnziUIUtility.selectChild(@driver,:id,"inputContact",nil,"input")
    		if inputContact.enabled? then
    			inputContact.send_keys(@records[0]['lead'][0]['lastname'])
    		end
    	end
    	if !elementTocheck2.empty? then
    		inputOpportunity = EnziUIUtility.selectChild(@driver,:id,"inputOpportunity",nil,"input")
    		if inputOpportunity.enabled? then
    			inputContact.send_keys(@records[0]['lead'][0]['Company'])
    		end
    	end
    	EnziUIUtility.setValue(@driver,:id,"building_autocomplete1_value","DC-Crystal City")
    	EnziUIUtility.wait(@driver,:class,"angucomplete-title",10)
		p = @driver.find_element(:class,"angucomplete-title")
		p.find_element(:tag_name,"span").click
    	elements = @driver.find_elements(:class,"booking-date")
    	date = DateTime.now
    	elements[0].send_keys "#{date.strftime("%Y")}-#{date.strftime("%m")}-#{date.strftime("%d")}"
    	wait = Selenium::WebDriver::Wait.new(:timeout => 100)
    	wait.until{  @driver.find_element(:id,"spinnerContainer")}
    	dropDowns = @driver.find_elements(:class,"table-form-control")
    	dropDowns.each do |dropDown|
    		if dropDown.text == "Select Time"
    			dropDown.click
    			options = dropDown.find_elements(:tag_name,"option")
    			if options.size > 1 then
    				options[2].click
    				puts options[2]
    			end
    			break
    		end
    	end
    	if buttonDisabled? then
    		EnziUIUtility.selectElement(@driver,"Book Tours","button")
    	end
    	
	end
	def buttonDisabled?
		@disabled = true
		allInputs = @driver.find_elements(:tag_name,"input")
		allInputs.each do |input|
			if input.attribute('value') != nil && input.attribute('required') == 'required' then
				@disabled = false
			else
				@disabled = true
			end
		end
		return @disabled
	end
	def objectCreated?(objectType,identifier,value)
		query = "SELECT id FROM #{objectType} WHERE #{identifier} = #{value}"
		result = Salesforce.getRecords(@salesforceBulk,"#{objectType}","#{query}",nil)
		return result.result.records[0]
	end
	def deleteTestData
		recordsToDelete = Array.new
		recordsToDelete.push(@recordInsertedIds['lead'])
		Salesforce.deleteRecords(@salesforceBulk,"Lead",recordsToDelete)
	end
end

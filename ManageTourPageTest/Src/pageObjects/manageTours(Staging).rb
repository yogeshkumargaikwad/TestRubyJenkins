#Created By : Monika Pingale
#Created Date : 28/12/2017
#Modified date :
require 'enziUIUtility'
require 'salesforce'
require 'selenium-webdriver'
require 'yaml'
require 'json'
require 'date'
require 'datatable'
class ManageTours
	@driver = nil
	@records = nil
	@recordsInJson = nil
	@@recordInsertedIds = nil
	@recordInsertedIdsToDelete = nil
	def initialize(driver,sandBoxType)
		@driver = driver
		@recordInsertedIdsToDelete = Hash.new
		@@recordInsertedIds = Hash.new
		recordFile = File.open(Dir.pwd+"/ManageTourPageTest/Src/testData/records.json", "r")
		recordsInJson = recordFile.read()
		@records = JSON.parse(recordsInJson)
		file = File.open("credentials.yaml", "r")
		@mapCredentials = YAML.load_file('credentials.yaml')
		@driver.get "https://test.salesforce.com/login.jsp?pw=#{@mapCredentials[sandBoxType]['password']}&un=#{@mapCredentials[sandBoxType]['username']}"
		@salesforceBulk = Salesforce.login(@mapCredentials["#{sandBoxType}"]['username'],@mapCredentials["#{sandBoxType}"]['password'],true)
		EnziUIUtility.wait(driver,:id,"tsid",100)
	end
	def insertTestData(dataToInsert,objectType)
		@@recordInsertedIds["#{objectType}"] = Salesforce.createRecords(@salesforceBulk,objectType,dataToInsert)
		if !@recordInsertedIdsToDelete.key?("#{objectType}") then
			@recordInsertedIdsToDelete["#{objectType}"] = [@@recordInsertedIds["#{objectType}"]]
		else
			@recordInsertedIdsToDelete["#{objectType}"] << @@recordInsertedIds["#{objectType}"]
		end
		puts @@recordInsertedIds["#{objectType}"]
	end
	def openPage(objectRecordId,findBy,value)
		url = @driver.current_url();
		newUrl = url.split('/home')
    	@driver.get "#{newUrl[0]}"+"/#{objectRecordId}"
    	EnziUIUtility.wait(@driver,findBy,"#{value}",10)
    	btn = @driver.find_element(findBy,"#{value}")
    	btn.click
    	newWindow = @driver.current_url();
    	EnziUIUtility.switchToWindow(@driver,newWindow)
    	EnziUIUtility.wait(@driver,:id,"FTE",100)
	end
	def bookTour(count, bookTour)
		wait = Selenium::WebDriver::Wait.new(:timeout => 100)
		wait.until { !@driver.find_elements(:id ,"FTE").empty? }
    	if !@driver.find_elements(:id,"Phone").empty? && @driver.find_element(:id,"Phone").attribute('value').eql?("") then
    		EnziUIUtility.setValue(@driver,:id,"Phone","#{@records[1]['tour'][count]['phone']}")
    	end
    	if !@driver.find_elements(:id,"FTE").empty? && @driver.find_element(:id,"FTE").attribute('value').eql?("") then
    		EnziUIUtility.setValue(@driver,:id,"FTE","#{@records[1]['tour'][count]['companySize']}")
    	end
    	if !@driver.find_elements(:id,"InterestedDesks").empty? && @driver.find_element(:id,"InterestedDesks").attribute('value').eql?("") then
    		EnziUIUtility.setValue(@driver,:id,"InterestedDesks","#{@records[1]['tour'][count]['numberOfDesks']}")
    	end
    	if !@driver.find_elements(:id,"Opportunity").empty? && @driver.find_element(:id,"Opportunity").attribute('value').eql?("") then
    		EnziUIUtility.setValue(@driver,:id,"Opportunity","#{@records[1]['tour'][count]['opportunity']}")
    	end
    	if !@driver.find_elements(:id,"BookTours#{count}").empty? then
		    container = @driver.find_element(:id,"BookTours#{count}")
    		#ManageTours.setElementValue(container,"tourBySalesLead","#{@records[1]['tour'][count]['bookedBySalesLead']}")
    		ManageTours.setElementValue(container,"productLine","#{@records[1]['tour'][count]['productLine']}")
    		ManageTours.selectBuilding(container,"#{@records[1]['tour'][count]['building']}")
    		wait.until {!@driver.find_element(:id ,"spinner").displayed?}
    		ManageTours.selectTourDate(container)
    		wait.until {!@driver.find_element(:id ,"spinner").displayed?}
    		#EnziUIUtility.clickElement(@driver,:id,"1515349800000")
    		wait.until {!@driver.find_element(:id ,"spinner").displayed?}
    		EnziUIUtility.selectElement(container,"Today","a")
    		wait.until {!@driver.find_element(:id ,"spinner").displayed?}
    		ManageTours.setElementValue(container,"startTime",nil)
    	end
    	wait.until {!@driver.find_element(:id ,"spinner").displayed?}
    	if bookTour then
   			EnziUIUtility.selectElement(@driver,"Book Tours","button")
   			newWindow = @driver.current_url();
    		EnziUIUtility.switchToWindow(@driver,newWindow)
    		EnziUIUtility.wait(@driver,:id,"enzi-data-table-container",100)
    	end
	end
	def self.selectBuilding(container,value)
		wait = Selenium::WebDriver::Wait.new(:timeout => 100)
		innerDiv = container.find_elements(:class,"building")
		innerFields = innerDiv[0].find_elements(:class,"cEnziField")
		innerFieldDivContainer = innerFields[3].find_elements(:tag_name,"div")
		inputFieldInnerDiv = innerFieldDivContainer[4].find_elements(:tag_name,"div")
		inputField = inputFieldInnerDiv[0].find_elements(:tag_name,"div")
		wait.until { inputFieldInnerDiv[9].find_elements(:tag_name,"input") }
      	if value == nil then
      		return inputFieldInnerDiv[9].find_elements(:tag_name,"input")[0]
      	end
      	inputFieldInnerDiv[9].find_elements(:tag_name,"input")[0].clear
		inputFieldInnerDiv[9].find_elements(:tag_name,"input")[0].send_keys "#{value}"
		wait.until { inputFieldInnerDiv[11].find_elements(:class,"slds-lookup__list")}
		list = inputFieldInnerDiv[11].find_elements(:tag_name,"ul")
		value = list[0].find_elements(:tag_name,"li")
		sleep(20)
		wait.until {value[1].displayed?}
		value[1].click
	end
	def self.selectTourDate(container)
		wait = Selenium::WebDriver::Wait.new(:timeout => 100)
		innerDiv = container.find_elements(:class,"tourDate")
		innerFields = innerDiv[0].find_elements(:class,"cEnziField")
		innerFieldDivContainer = innerFields[3].find_elements(:tag_name,"div")
		inputFieldOuterDiv = innerFieldDivContainer[4].find_elements(:tag_name,"div")
		inputFieldInnerDiv = inputFieldOuterDiv[0].find_elements(:tag_name,"div")
		wait.until { inputFieldInnerDiv[7].displayed? }
		if inputFieldInnerDiv[7].displayed? then
			sleep(10)
			inputFieldInnerDiv[7].click
		end
		inputFieldInnerDiv[7].find_elements(:tag_name,"input")[0]
	end
	def self.getElement(tagName,elementToset,container)
		innerDiv = container.find_elements(:class,"#{elementToset}")
		innerFields = innerDiv[0].find_elements(:class,"cEnziField")
		innerFieldDivContainer = innerFields[3].find_elements(:tag_name,"div")
		innerFieldDivContainer[4].find_elements(:tag_name,"#{tagName}")
	end
	def self.setElementValue(container,elementToset,value)
		dropdown = 	ManageTours.getElement("select",elementToset,container)
		if value != nil then
			EnziUIUtility.selectElement(dropdown[0],"#{value}","option")
		end
		if dropdown[0].find_elements(:tag_name,"option").size > 1 then
			dropdown[0].find_elements(:tag_name,"option")[1].click
		end
		dropdown[0]
	end
	def self.getChildByClassName(childs,className)
		childFound = nil
		childs.each do |child|
			if child.attribute('class').eql? "#{className}" then
				childFound = child
				break
			end
		end
		return childFound
	end
	def duplicateAccountSelector(option,account)
		wait = Selenium::WebDriver::Wait.new(:timeout => 100)
		if account.eql? nil then
			EnziUIUtility.wait(@driver,:id,"header43",100)
			EnziUIUtility.selectElement(@driver,"#{option}","button")
			wait.until { !@driver.find_element(:id ,"spinner").displayed? }
			EnziUIUtility.wait(@driver,:id,"enzi-data-table-container",100)
			wait.until { !@driver.find_element(:id ,"spinner").displayed? }
			sleep(10)
		else
			if !@driver.find_elements(:class ,"slds-radio_faux").empty? then
				@driver.find_elements(:class ,"slds-radio_faux")[0].click
				EnziUIUtility.selectElement(@driver,"#{option}","button")
			end
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
	def numberOfTourBooked
		EnziUIUtility.wait(@driver,:id,"enzi-data-table-container",1000)
		tourBookedtable = EnziUIUtility.selectChild(@driver,:id,"enzi-data-table-container",nil,"table")
		puts tourBookedtable[0].find_elements(:tag_name,"tr").size
		tourBookedtable[0].find_elements(:tag_name,"tr").size
	end
	def childDisabled?(parent,child)
	if parent.attribute('value').eql? "" then
			!child.enabled?
		else
			!child.enabled?
		end
	end
	def checkRecordCreated(object,query)
		result = Salesforce.getRecords(@salesforceBulk,"#{object}","#{query}",nil)
		if !object.eql? 'Lead' then
			@@recordInsertedIds["#{object}"] = result.result.records[0]
		else
			@@recordInsertedIds["Lead1"] = result.result.records[0]
			puts "Lead created => #{@@recordInsertedIds['Lead1']}"
		end
		if !@recordInsertedIdsToDelete.key?("#{object}") then
			@recordInsertedIdsToDelete["#{object}"] = [@@recordInsertedIds["#{object}"]]
			puts "Id to delete of #{object} is #{@recordInsertedIdsToDelete[object]}"
		else
			@recordInsertedIdsToDelete["#{object}"] << @@recordInsertedIds["#{object}"]
			puts "Id to delete of #{object} is #{@recordInsertedIdsToDelete[object]}"
		end
		puts "#{object} created => #{@@recordInsertedIds[object]}"
		result.result.records
	end
	def bookNewTour
		EnziUIUtility.wait(@driver,:class,"visible",1000)
		newButtonContainer = @driver.find_element(:class,"visible")
		EnziUIUtility.wait(@driver,:class,"lightningPrimitiveIcon",1000)
		newButtonContainer.find_elements(:class,"lightningPrimitiveIcon")[0].click
	end
	def openPageForLead(id)
		puts "opening page for id = #{id}"
		newUrl = @driver.current_url.split("=")[0]
		EnziUIUtility.navigateToUrl(@driver,"#{newUrl}=#{id}")
		puts "navigated to #{@driver.current_url()}"
		newWindow = @driver.current_url();
    	EnziUIUtility.switchToWindow(@driver,newWindow)
	end
	def checkError(errorMessage)
		 @driver.find_elements(:class,"slds-theme--error")[0].text.eql? "#{errorMessage}"
	end
	def deleteTestData
		Salesforce.deleteRecords(@salesforceBulk,"Lead",@recordInsertedIdsToDelete['Lead'][0])
		Salesforce.deleteRecords(@salesforceBulk,"Journey__c",@recordInsertedIdsToDelete['Journey__c'])
		Salesforce.deleteRecords(@salesforceBulk,"Account",@recordInsertedIdsToDelete['Account'])
		Salesforce.deleteRecords(@salesforceBulk,"Contact",@recordInsertedIdsToDelete['Contact'])
		Salesforce.deleteRecords(@salesforceBulk,"Opportunity",@recordInsertedIdsToDelete['Opportunity'])
		Salesforce.deleteRecords(@salesforceBulk,"Tour_Outcome__c",@recordInsertedIdsToDelete['Tour_Outcome__c'])
	end
	def rescheduleTour
		wait = Selenium::WebDriver::Wait.new(:timeout => 100)
		EnziUIUtility.wait(@driver,:id,"enzi-data-table-container",1000)
		EnziUIUtility.selectElement(@driver,"Reschedule","button")
		EnziUIUtility.wait(@driver,:id,"header43",100)
		wait.until { @driver.find_element(:id ,"StartTime").displayed? }
		EnziUIUtility.clickElement(@driver,:id,"StartTime")
		EnziUIUtility.selectChild(@driver,:id,"StartTime",nil,"option")[4].click
		EnziUIUtility.selectElement(@driver,"Save","button")
		#EnziUIUtility.wait(@driver,:id,"Reschedule",1000)
		wait.until { @driver.find_element(:id ,"enzi-data-table-container").displayed? }
		#res.fetch('Status__c').eql?("Scheduled") && res.fetch('Original_Tour__c').eql?("#{@@recordInsertedIds['Tour_Outcome__c']['Id']}")
	end
	def tourStatusChecked?(statusToCheck)
		tourStatusChecked = false
		rescheduledTours = Salesforce.getRecords(@salesforceBulk,"Tour_Outcome__c","SELECT id,Status__c,Original_Tour__c FROM Tour_Outcome__c WHERE Primary_Member__r.email = '#{@records[0]['lead'][3]['email']}'",nil)
		rescheduledTours.result.records.each do |res|
			@@recordInsertedIds['Tour_Outcome__c1'] = res
			if res.fetch('Status__c').eql? "#{statusToCheck}" then
				tourStatusChecked = true
			end
		end
		return tourStatusChecked
	end
end


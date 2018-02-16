#Created By 	: Pragalbha Mahajan
#Created Date : 22/01/2018
#Modified date:

require "selenium-webdriver"
require 'enziUIUtility'
require 'salesforce'
require "rspec"

#require_relative '../Utility/httparty/SfRESTService'

class EnterPrise

	def initialize(driver)
		@driver = driver
		file = File.open("credentials.yaml", "r")
		mapCredentials = YAML.load(file.read())
		@driver.get "https://test.salesforce.com/login.jsp?pw=#{mapCredentials['ENTQA']['password']}&un=#{mapCredentials['ENTQA']['username']}"
		@salesforceBulk = Salesforce.login(mapCredentials['ENTQA']['username'],mapCredentials['ENTQA']['password'],true)
		@@userName = nil
		file = File.open("timeSettings.yaml", "r")
		@timeSetting = YAML.load(file.read())

		#EnziUIUtility.wait(@driver,:id,"phSearchInput",100)
		EnziUIUtility.wait(@driver,:id,"phSearchInput",@timeSetting['Wait']['Environment']['Classic'])
		#@driver.find_element(id: 'Contact_Tab').click
	end

	#Use: This function is used to get Driver
	def getDriver
		@driver
	end

	#Use: This function is used to go to users
	def redirectToUsers
		@driver.get "https://wework--entqa.cs68.my.salesforce.com/005?isUserEntityOverride=1&retURL=/ui/setup/Setup?setupid=Users&setupid=ManageUsers"
	end

	#Use: This function is Used to Login with a specified Profile
	def loginForUser(profile_name)
=begin
		user = Salesforce.getRecords(@salesforceBulk,"User","SELECT username FROM user WHERE profile.Name = '#{profile_name}' and isActive = true LIMIT 1")
		userName = user.result.records[0]
		puts "user records: #{user.result.records}"
  		puts "user record: #{user.result.records[0]}"
  		puts "userName: #{userName}"
  		puts "user records size: #{user.result.records.size}"
=end

		allTables = @driver.find_elements(:tag_name,"table")
		loginTable = nil
		allTables.each do |tab|
			if tab.attribute('class') == "list"
				loginTable = tab
				break
			end
		end
		tBodyEle = loginTable.find_element(:tag_name,'tbody')
		arrRows = tBodyEle.find_elements(:tag_name,'tr')
		arrRows.each do |row|
			row.find_elements(:tag_name,'td').each do |col|
				#puts "Column data lable: #{col.text}"
				if(col.text == "#{profile_name}")
					@@userName = row.find_element(:tag_name,'th').text
					#puts "userName: #{@@userName}"
					row.find_element(:link, 'Login').click
					return nil
				end
			end
		end
	end

	#Use:This function is use to set the date
	def setMoveInDate(date)
		EnziUIUtility.wait(@driver,:id,'Term__c',@timeSetting['Wait']['Environment']['Lightening'])
		#@driver.find_element(:name,'Move_In_Date__c').click
		arr_date = date.split('-')
		year_to_select = arr_date[0]
		@driver.find_element(:class,'year').find_elements(:tag_name,"option").each do|option|
			if option.text==year_to_select
				option.click
				break
			end
		end

		next_button = nil
		prev_button = nil
		@driver.find_elements(:tag_name,'button').each do |button|
			if button.attribute('title')=='Next Month'
				next_button = button
			elsif button.attribute('title')=='Previous Month'
				prev_button = button
			end
		end

		hash_month = {"January"=>1,"February"=>2,"March"=>3,"April"=>4,"May"=>5,"June"=>6,"July"=>7,"August"=>8,"September"=>9,"October"=>10,"November"=>11,"December"=>12}
		month_to_select = arr_date[1].to_i

		while true do
			if hash_month[@driver.find_element(:id,'month').text] == month_to_select
				break
			elsif hash_month[@driver.find_element(:id,'month').text] > month_to_select
				prev_button.click
			else
				next_button.click
			end
		end

		day_to_select = arr_date[2]
		@driver.find_element(:class,'slds-datepicker__month').find_elements(:class,'slds-day').each do |day|
			if day.text == day_to_select then
				#submitButtonEnability = @driver.find_element(:id, "btnSubmit").enabled?
				#puts "day.Id is: #{day.attribute('id')}"
				if day.attribute('id').empty? != true then
					puts "Day id empty?: #{day.attribute('id').empty?}"
					day.click
					return true
				else
					#puts "Day id empty?: #{day.attribute('id').empty?}"
					@driver.find_element(:link, 'Close').click
					return false
				end
			end
		end
	end

	def checkError(elementTosearch,textToCheck)
		all_Elements = @driver.find_elements(:tag_name,"#{elementTosearch}")
		all_Elements.each do |element|
			#select element by provided text
			if textToCheck != nil then
				#puts element.text
				if element.text == textToCheck then
					#puts "matched"
					return true
				end
			end
		end
		return false
	end

	#Use: This function is Used to Navigate To Create Opportunity
	def navigateToCreateOpportunity()
		EnziUIUtility.wait(@driver,:class,"globalCreateTrigger",@timeSetting['Wait']['Environment']['Lightening'])
		@driver.find_element(:class,'globalCreateTrigger').click
		@driver.find_element(:link, 'Create Opportunity').click
	end

	def createNewOrganization(orgName, noOfEmployees = nil)
		EnziUIUtility.wait(@driver,:id,'GlobalActionManager:New_Organization',@timeSetting['Wait']['Environment']['Lightening'])
		EnziUIUtility.clickElement(@driver,:id,"GlobalActionManager:New_Organization")
		EnziUIUtility.wait(@driver,:id,'Name',@timeSetting['Wait']['Environment']['Lightening'])
		EnziUIUtility.setValue(@driver,:id,'Name',"#{orgName}")
		if noOfEmployees != nil
			EnziUIUtility.setValue(@driver,:id,'Number_of_Full_Time_Employees__c',"#{noOfEmployees}")
		end
		selectElement(@driver,"Save","button")
		#expect(@objEnterPrise.checkStage("div","Account created.")).to eq true
		EnziUIUtility.wait(@driver,:id, "Budget_Monthly__c",@timeSetting['Wait']['Environment']['Lightening'])
	end

	def createNewContact(accountName, contactName, emailId)
		@driver.navigate.refresh
		navigateToCreateOpportunity()
		EnziUIUtility.wait(@driver,:id,'Budget_Monthly__c',@timeSetting['Wait']['Environment']['Lightening'])
		selectElement(@driver,"Maximize","button")
		EnziUIUtility.setValue(@driver,:id,"AccountRec","#{accountName}")
		sleep(10)
		@driver.find_element(:id,'AccountReclist').find_elements(:tag_name,"li").each do |list|
			if list.attribute('title') == "#{accountName}"
				puts "list title: #{list.attribute('title')}"
				wait = Selenium::WebDriver::Wait.new(:timeout => 30);
				#sleep(20)
				wait.until {list.displayed?}
				list.click
			end
		end
		EnziUIUtility.wait(@driver,:id,'actionManager:New_Decision_Maker',@timeSetting['Wait']['Environment']['Lightening'])
		sleep(5)
		EnziUIUtility.clickElement(@driver,:id,"actionManager:New_Decision_Maker")
		EnziUIUtility.wait(@driver,:id,'Name',@timeSetting['Wait']['Environment']['Lightening'])
		EnziUIUtility.setValue(@driver,:id,'Name',"#{contactName}")
		EnziUIUtility.setValue(@driver,:id,'Email',"#{emailId}")
		selectElement(@driver,"Save","button")
	end

	#Use: This function is Used to check button Enability
	def buttonEnabled?(buttonId)
		EnziUIUtility.wait(@driver,:id,"#{buttonId}",@timeSetting['Wait']['Environment']['Lightening'])
		buttonEnability = @driver.find_element(:id, "#{buttonId}").enabled?
		puts "button Enability?: #{buttonEnability}"
		return buttonEnability
	end

	#Use: This function is Used to Select Element
	def selectElement(driver,textToselect,elementTosearch)
		all_Elements = driver.find_elements(:tag_name,"#{elementTosearch}")
		all_Elements.each do |element|
			#select element by provided text
			if textToselect != nil then
				#puts element.text
				if element.text == textToselect then
					#puts "matched"
					element.click
					break
				end
			end
		end
	end

	#Use: This function is Used to Navigate To AccountDetails
	def navigateToAccountDetails(tab_name)
		@driver.find_element(:link, "#{tab_name}").click
		EnziUIUtility.wait(@driver,nil,nil,@timeSetting['Sleep']['Environment']['Lightening'])
		arrTable = @driver.find_elements(:tag_name,'table')
		accountTable = nil
		#puts "tables: #{arrTable}"
		arrTable.each do|table|
			#puts "Table Class: #{table.attribute('class')}"
			if table.attribute('class') == 'slds-table forceRecordLayout slds-table--header-fixed slds-table--edit slds-table--bordered resizable-cols slds-table--resizable-cols uiVirtualDataTable'
				accountTable = table
				break
			end
		end
		#puts "accountTable: #{accountTable.attribute('class')}"
		tBodyEle = accountTable.find_element(:tag_name,'tbody')
		arrRows = tBodyEle.find_elements(:tag_name,'tr')
		#puts "arrRows: #{arrRows}"
		arrRows.each do |row|
			#puts "Row class: #{row}"
			tHead = row.find_element(:tag_name,'th')
			#puts "tHead: #{tHead.attribute('class')}"
			tHead.find_element(:tag_name,'a').click
			break
		end
	end

	def recordDeletionDemo(objName, fieldToSelect, fieldToFilter, fieldToFilterVal)

	end

	#Use: This function is used to get Opportunity fields
	def getOpportunityFields(recordId)
		recordDetails = Salesforce.getRecords(@salesforceBulk,"Opportunity","select Id, isdeleted, StageName, Stage_Details__c, Opportunity_Account_Name__c, Owner_Auto_Assign__c, Main_Contact_ID__c, AccountId, Decision_Maker__c, Building__c, OwnerId, Owner.Name, Decision_Maker__r.Name from Opportunity where Id = '#{recordId}'",key = nil)
		return recordDetails.result.records[0]#.fetch("Id"), recordDetails.result.records[0].fetch("IsDeleted"), recordDetails.result.records[0].fetch("StageName")
	end

	#Use: This function is used to get Account fields
	def getAccountFields(recordName)
		recordDetails = Salesforce.getRecords(@salesforceBulk,"Account","select Id, isdeleted from Account where Name = '#{recordName}'",key = nil)
		accId = recordDetails.result.records[0].fetch("Id")
		#puts "accId: #{accId}"
		return recordDetails.result.records[0]
	end

	def getAccountFieldsById(recordId)
		recordDetails = Salesforce.getRecords(@salesforceBulk,"Account","select Id, Name, isdeleted from Account where Id = '#{recordId}'",key = nil)
		#@@accountId = recordDetails.result.records[0].fetch("Id")
		return recordDetails.result.records[0]
	end

	def getContactFields(recordEmail)
		recordDetails = Salesforce.getRecords(@salesforceBulk,"Contact","select Id, Name, isdeleted from Contact where Email = '#{recordEmail}'",key = nil)
		#@@accountId = recordDetails.result.records[0].fetch("Id")
		return recordDetails.result.records[0]
	end

	def getContactFieldsById(recordId)
		recordDetails = Salesforce.getRecords(@salesforceBulk,"Contact","select Name, isdeleted from Contact where Id = '#{recordId}'",key = nil)
		#@@accountId = recordDetails.result.records[0].fetch("Id")
		return recordDetails.result.records[0]
	end

	def getBuildingFields(recordId)
		recordDetails = Salesforce.getRecords(@salesforceBulk,"Building__c","select Name from Building__c where Id = '#{recordId}'",key = nil)
		return recordDetails.result.records[0]#.fetch("Id"), recordDetails.result.records[0].fetch("IsDeleted"), recordDetails.result.records[0].fetch("StageName")
	end

	def getOpportunity_RoleFields(oppId)
		recordDetails = Salesforce.getRecords(@salesforceBulk,"Opportunity_Role__c","select Name, Id, Is_Primary_Member__c, Role__c from Opportunity_Role__c where Opportunity__c = '#{oppId}'",key = nil)
		return recordDetails.result.records[0]#.fetch("Id"), recordDetails.result.records[0].fetch("IsDeleted"), recordDetails.result.records[0].fetch("StageName")
	end

	#Use: This function is Used to switching to lightening from classic
	def switchToLightening()
		if !(driver.current_url().include? "lightning")
			#puts "String not 'lightning'"
			EnziUIUtility.wait(driver,:id,"userNav-arrow",@timeSetting['Wait']['Environment']['Classic'])
			driver.find_element(:id, "userNav-arrow").click
			EnziUIUtility.wait(driver,:id,"userNav-arrow",@timeSetting['Wait']['Environment']['Classic'])
			driver.find_element(:link , "Switch to Lightning Experience").click
		else
			puts "You are already on lightening..."
		end
	end

	#Use: This function is Used to switching to classic from lightening
	def switchToClassic()
		if (@driver.current_url().include? "lightning")
			#puts "String 'lightning'"
			EnziUIUtility.wait(@driver,:class,"oneUserProfileCardTrigger",@timeSetting['Wait']['Environment']['Lightening'])
			@driver.find_element(:class, "oneUserProfileCardTrigger").click
			EnziUIUtility.wait(@driver,:class,"profile-card-footer",@timeSetting['Wait']['Environment']['Lightening'])
			@driver.find_element(:link , "Switch to Salesforce Classic").click
		else
			puts "You are already on Classic..."
		end
	end

=begin
	#Use: This function is Used to Navigate To Create Opportunity

	def navigateToCreateOpportunity()
		begin
			EnziUIUtility.wait(@driver,:class,"sldsButtonHeightFix",100)
			@driver.find_element(:class, 'sldsButtonHeightFix').click
			puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
			puts @driver.find_elements(:link, "Create Opportunity")[0].displayed?
			if @driver.find_elements(:link, "Create Opportunity")[0].displayed? == false then
				@driver.find_element(:class, 'sldsButtonHeightFix').click
				@driver.find_element(:link, "Create Opportunity").click
			else
				@driver.find_element(:link, "Create Opportunity").click
			end
		rescue Exception => e
			puts e
			@driver.find_element(:class, 'sldsButtonHeightFix').click
			if @driver.find_elements(:link , "Create Opportunity")[0].displayed? == false then
				@driver.find_element(:class, 'sldsButtonHeightFix').click
				@driver.find_element(:link, "Create Opportunity").click
			else
				@driver.find_element(:link, "Create Opportunity").click
			end
		end
	end
=end


	#Use: This function is Used to get element
	# e.g. getElementByAttribute(:elementFindBy,"elementIdentity","attributeName","attributeValue")
	def getElementByAttribute(elementFindBy,elementIdentity,attributeName,attributeValue)
		#puts "in getElementByAttribute"
		elements = @driver.find_elements(elementFindBy, elementIdentity)
		elements.each do |element|
		#puts option.text
		#puts option.attribute("href")
			if element.attribute(attributeName) != nil then
				if element.attribute("href").include? attributeValue then
					return element
					break
				end
			end
		end
	end

	def getOpportunityTeamMemberFields(oppId)
		recordDetails = Salesforce.getRecords(@salesforceBulk,"OpportunityTeamMember","SELECT Id, Name FROM OpportunityTeamMember WHERE OpportunityId = '#{oppId}'",key = nil)
		puts "team member name: #{recordDetails.result.records[0].fetch("Name")}"
		return recordDetails.result.records[0]
	end

	def delRecord(objName)
		allRecords = Salesforce.class_variable_get(:@@createdRecordsIds)
		#puts "allRecords: #{allRecords}"
		Salesforce.deleteRecords(@salesforceBulk,"#{objName}",allRecords["#{objName}"])
	end

	def createOpportunity(opportunityRole, oppRoleContact, buildingName, accountName, noOfFTE = nil, noOfDeskInterestedIn = nil, monthlyBudget = nil, location = nil, officeFormat = nil, moveInDate = nil, sqFeet = nil, term = nil, useCase = nil)
		@driver.navigate.refresh
		navigateToCreateOpportunity()
		EnziUIUtility.wait(@driver,:id,'Budget_Monthly__c',@timeSetting['Wait']['Environment']['Lightening'])
		selectElement(@driver,"Maximize","button")

		EnziUIUtility.setValue(@driver,:id,"AccountRec","#{accountName}")
		sleep(10)
		@driver.find_element(:id,'AccountReclist').find_elements(:tag_name,"li").each do |list|
			if list.attribute('title') == "#{accountName}"
				#puts "list title: #{list.attribute('title')}"
				wait = Selenium::WebDriver::Wait.new(:timeout => 30);
				#sleep(20)
				wait.until {list.displayed?}
				list.click
			end
		end
		EnziUIUtility.wait(@driver,nil,nil,@timeSetting['Sleep']['Environment']['Lightening'])
		if(noOfFTE != nil)
			EnziUIUtility.setValue(@driver,:id,"Number_of_Full_Time_Employees__c","#{noOfFTE}")
		end

		if(noOfDeskInterestedIn != nil)
			EnziUIUtility.setValue(@driver,:id,"Interested_in_Number_of_Desks__c",2)
		end

		if(monthlyBudget != nil)
			EnziUIUtility.setValue(@driver,:id,"Budget_Monthly__c",100)
		end

		EnziUIUtility.selectOption(@driver,:id,"Role__c","#{opportunityRole}")
		@driver.find_element(:id, "OppRoleContact").clear()
		EnziUIUtility.setValue(@driver,:id,"OppRoleContact","#{oppRoleContact}")
		sleep(10)
		@driver.find_element(:id,'OppRoleContactlist').find_elements(:tag_name,"li").each do |list|
			if list.attribute('title') == "#{oppRoleContact}"
				#puts "list title: #{list.attribute('title')}"
				wait = Selenium::WebDriver::Wait.new(:timeout => 40);
				#sleep(30)
				wait.until {list.displayed?}
				list.click
			end
		end
		EnziUIUtility.wait(@driver,nil,nil,@timeSetting['Sleep']['Environment']['Lightening'])
		@driver.execute_script("arguments[0].scrollIntoView();" , @driver.find_element(:id ,"Term__c"))

		EnziUIUtility.setValue(@driver,:id,"Building","#{buildingName}")
		#EnziUIUtility.wait(@driver,:id,'Buildinglist',15)
		sleep(10)
		@driver.find_element(:id,'Buildinglist').find_elements(:tag_name,"li").each do |list|
			if list.attribute('title') == "#{buildingName}"
				#puts "list title: #{list.attribute('title')}"
				wait = Selenium::WebDriver::Wait.new(:timeout => 30);
				#sleep(30)
				wait.until {list.displayed?}
				list.click
			end
		end
		EnziUIUtility.wait(@driver,nil,nil,@timeSetting['Sleep']['Environment']['Lightening'])
		if(officeFormat != nil)
			EnziUIUtility.selectOption(@driver,:id,"OfficeFormat","#{officeFormat}")
		end

		if(moveInDate != nil)
			EnziUIUtility.wait(@driver,:id,'Move_In_Date__c',@timeSetting['Wait']['Environment']['Lightening'])
			@driver.find_element(:id,'Move_In_Date__c').click
			setMoveInDate(moveInDate)
		end

		if(sqFeet != nil)
			EnziUIUtility.setValue(@driver,:id,"Sq_Feet_Requested__c","#{sqFeet}")
		end

		if(term != nil)
			EnziUIUtility.setValue(@driver,:id,"Term__c","#{term}")
		end

		if(useCase != nil)
			EnziUIUtility.selectOption(@driver,:id,"Use_Case__c","#{useCase}")
		end

=begin
		if(noOfFTE != nil)
			EnziUIUtility.selectOption(@driver,:id,"LeadSource","#{}")
		end

		if(noOfFTE != nil)
			EnziUIUtility.setValue(@driver,:id,"Description","#{sqFeet}")
		end
=end

		selectElement(@driver,"Save & Close","button")
		sleep(10)
		urlArr = @driver.current_url.split('/')
		#puts "urlArr: #{urlArr}"
		#puts "urlArr[6]: #{urlArr[6]}"
		oppId = urlArr[6]
		return oppId
	end

	#Use: This function is Used to Logged out
	def logOut()
		userNameWords = @@userName.split(/\W+/)
		arrSize = userNameWords.size
		puts "userNameWords size: #{arrSize}"

		puts userNameWords[arrSize-1]
		puts "user Name Words: #{userNameWords}"
		puts userNameWords[0]
		puts userNameWords[1]
		puts userNameWords[2]
		if arrSize == 3
			selectElement(@driver,"Log out as #{userNameWords[arrSize-1]} #{userNameWords[0]} #{userNameWords[1]}","a")
		elsif arrSize == 4
			selectElement(@driver,"Log out as #{userNameWords[arrSize-1]} #{userNameWords[0]} #{userNameWords[1]} #{userNameWords[2]}","a")
		end

=begin
		@driver.find_elements(:tag_name,'button').each do |btn|
			if btn.attribute('class') == 'bare slds-button uiButton forceHeaderButton oneUserProfileCardTrigger'
				btn.click
				@driver.find_element(:class, 'bare slds-button uiButton forceHeaderButton oneUserProfileCardTrigger').find_elements(:tag_name,'a').each do |anchor|
					puts "#{anchor.attribute('a')}"
				end
				@driver.find_element(:linkText, 'Log Out').click
			end
		end

		def createOpportunityFromAccounts()
  			@driver.find_element(:class, "slds-button slds-button--icon-border-filled oneActionsDropDown").find_element(:tag_name,'a').click
  		end
=end
	end
end


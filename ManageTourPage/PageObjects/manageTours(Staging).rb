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
	@@recordInsertedIds = nil
	def initialize(driver,sandBoxType)
		@driver = driver
		@@recordInsertedIds = Hash.new
		@records = JSON.parse(File.read(Dir.pwd+"/ManageTourPage/TestData/records.json"))
		@timeSettingMap = YAML.load_file(Dir.pwd+'/timeSettings.yaml')
		@mapCredentials = YAML.load_file(Dir.pwd+'/credentials.yaml')
		@selectorSettingMap = YAML.load_file(Dir.pwd+'/ManageTourPage/TestData/selectorSetting.yaml')
		@selectorSettingMap['screenSize']['actual'] = @driver.manage.window.size.width
		@wait = Selenium::WebDriver::Wait.new(:timeout => @timeSettingMap['Wait']['Environment']['Lightening']['Min'])

		#@driver.get "https://test.salesforce.com/login.jsp?pw=#{@mapCredentials[sandBoxType]['password']}&un=#{@mapCredentials[sandBoxType]['username']}"
		@salesforceBulk = Salesforce.login(@mapCredentials["#{sandBoxType}"]['username'],@mapCredentials["#{sandBoxType}"]['password'],true)
		#EnziUIUtility.wait(driver,:id,"tsid",@timeSettingMap['Wait']['Environment']['Classic']['Min'])
	end
	def openPage(objectRecordId,findBy,value)
		url = @driver.current_url();
		newUrl = url.split('/')
    	@driver.get "#{newUrl[0]}//#{newUrl[2]}/#{objectRecordId}"
    	if !(@driver.current_url().include? "lightning")
    		EnziUIUtility.wait(@driver,findBy,"#{value}",@timeSettingMap['Wait']['Environment']['Classic']['Min'])
    		btn = @driver.find_element(findBy,"#{value}")
    		btn.click
    	else
    		EnziUIUtility.wait(@driver,:class,"oneActionsDropDown",@timeSettingMap['Wait']['Environment']['Lightening']['Max'])
    		@driver.find_elements(:class,"oneActionsDropDown")[0].click
    		EnziUIUtility.wait(@driver,:class,"forceActionLink",@timeSettingMap['Wait']['Environment']['Lightening']['Max'])
    		EnziUIUtility.selectElement(@driver,"Manage/Book a Tour","a")
    		if !(@driver.find_elements(:xpath ,"//iframe[starts-with(@id,'vfFrameId')]").size > 0)
    			EnziUIUtility.wait(@driver,:class,"uiMenuItem",@timeSettingMap['Wait']['Environment']['Lightening']['Max'])
    			EnziUIUtility.selectElement(@driver,"Manage/Book a Tour","a")
    		end
    	end
    	EnziUIUtility.switchToWindow(@driver,@driver.current_url())
    	if @driver.current_url().include? "lightning" then
			EnziUIUtility.wait(@driver,:class,"panelSlide",@timeSettingMap['Wait']['Environment']['Lightening']['Max'])
			EnziUIUtility.wait(@driver,:xpath,"//iframe[starts-with(@id,'vfFrameId')]",@timeSettingMap['Wait']['Environment']['Lightening']['Max'])
			EnziUIUtility.switchToFrame(@driver,@driver.find_element(:xpath ,"//iframe[starts-with(@id,'vfFrameId')]").attribute('name'))
		end
    	#EnziUIUtility.wait(@driver,:id,"FTE",@timeSettingMap['Wait']['Environment']['Lightening']['Min'])
	end
	def bookTour(count, bookTour)
		@wait.until { @driver.find_elements(:id ,"FTE") }
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
    		EnziUIUtility.wait(@driver,:id,"BookTours#{count}",@timeSettingMap['Wait']['Environment']['Lightening']['Max'])
		    container = @driver.find_element(:id,"BookTours#{count}")
    		#ManageTours.setElementValue(container,"tourBySalesLead","#{@records[1]['tour'][count]['bookedBySalesLead']}")
    		if @driver.find_elements(:class,"productLine").size > 0 then
    			ManageTours.setElementValue(container,"productLine","#{@records[1]['tour'][count]['productLine']}")
    		else
    			ManageTours.setElementValue(container,"productLine2","#{@records[1]['tour'][count]['productLine']}")
    		end
    		ManageTours.selectBuilding(container,"#{@records[1]['tour'][count]['building']}",@timeSettingMap,@driver,@selectorSettingMap)
    		@wait.until {!@driver.find_element(:id ,"spinner").displayed?}
    		ManageTours.selectTourDate(container,@timeSettingMap,@driver,@selectorSettingMap)
    		@wait.until {!@driver.find_element(:id ,"spinner").displayed?}
    		#EnziUIUtility.clickElement(@driver,:id,"1515349800000")
    		@wait.until {!@driver.find_element(:id ,"spinner").displayed?}
				if Date.today.next_day(1).saturday? then
					@wait.until {container.find_element(:id ,Date.today.next_day(3).to_s)}
					container.find_element(:id ,Date.today.next_day(3).to_s).click
				else
					@wait.until {container.find_element(:id ,Date.today.next_day(1).to_s)}
					container.find_element(:id ,Date.today.next_day(1).to_s).click
					#EnziUIUtility.selectElement(@driver.find_element(:id,"BookTours#{count}"),"Today","a")
				end
    		@wait.until {!@driver.find_element(:id ,"spinner").displayed?}
    		if  @driver.find_elements(:class,"startTime").size > 0 then
    			ManageTours.setElementValue(container,"startTime",nil)
    		else
    			ManageTours.setElementValue(container,"startTime2",nil)
    		end
    		
    	end
    	@wait.until {!@driver.find_element(:id ,"spinner").displayed?}
    	if bookTour then
   			EnziUIUtility.selectElement(@driver,"Book Tours","button")
    		#EnziUIUtility.switchToWindow(@driver,@driver.current_url())
    		EnziUIUtility.wait(@driver,:id,"header43",@timeSettingMap['Wait']['Environment']['Lightening']['Max'])
    	end
	end
	def self.selectBuilding(container,value,waitTime,driver,selector)
		wait = Selenium::WebDriver::Wait.new(:timeout => waitTime['Wait']['Environment']['Lightening']['Min'])
		if driver.find_elements(:class,"building").size > 0 then
			innerDiv = container.find_elements(:class,"building")
		else
			innerDiv = container.find_elements(:class,"building2")
		end
		
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

    	sleep(waitTime['Sleep']['Environment']['Lightening']['Min'])
		list = inputFieldInnerDiv[11].find_elements(:tag_name,"ul")
		value = list[0].find_elements(:tag_name,"li")
		wait.until {value[1].displayed?}
		value[1].click
	end
	def self.selectTourDate(container,waitTime,driver,selector)
		wait = Selenium::WebDriver::Wait.new(:timeout => waitTime['Wait']['Environment']['Lightening']['Min'])
		if driver.find_elements(:class,"tourDate").size > 0 then
			innerDiv = container.find_elements(:class,"tourDate")
		else
			innerDiv = container.find_elements(:class,"tourDate2")
		end
		innerFields = innerDiv[0].find_elements(:class,"cEnziField")
		innerFieldDivContainer = innerFields[3].find_elements(:tag_name,"div")
		inputFieldOuterDiv = innerFieldDivContainer[4].find_elements(:tag_name,"div")
		inputFieldInnerDiv = inputFieldOuterDiv[0].find_elements(:tag_name,"div")
		wait.until { inputFieldInnerDiv[7].displayed? }
    	sleep(waitTime['Sleep']['Environment']['Lightening']['Min'])
		if inputFieldInnerDiv[7].displayed? then
      	wait.until { inputFieldInnerDiv[7].displayed? }
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
		if account.eql? nil then
			EnziUIUtility.wait(@driver,:id,"header43",@timeSettingMap['Wait']['Environment']['Lightening']['Max'])
			EnziUIUtility.selectElement(@driver,"#{option}","button")
			if @driver.find_elements(:id ,"header43").size > 0
				EnziUIUtility.selectElement(@driver,"#{option}","button")
			end

			@wait.until { !@driver.find_element(:id ,"spinner").displayed? }
			EnziUIUtility.wait(@driver,:id,"enzi-data-table-container",@timeSettingMap['Wait']['Environment']['Lightening']['Min'])
			@wait.until { !@driver.find_element(:id ,"spinner").displayed? }
			sleep(@timeSettingMap['Sleep']['Environment']['Lightening']['Min'])
		else
			@wait.until { @driver.find_element(:class ,"slds-radio_faux").displayed? }
			if !@driver.find_elements(:class ,"slds-radio_faux").empty? then
				@driver.find_elements(:class ,"slds-radio_faux")[0].click
				@driver.find_elements(:class ,"slds-radio_faux")[0].click
				EnziUIUtility.selectElement(@driver,"#{option}","button")
			end
      		
      		@wait.until { !@driver.find_element(:id ,"spinner").displayed? }
		end
	end
	def buttonDisabled?
		disabled = true
		allInputs = @driver.find_elements(:tag_name,"input")
		allInputs.each do |input|
			if input.attribute('value') != nil && input.attribute('required') == 'required' then
				disabled = false
			else
				disabled = true
			end
		end
		return disabled
	end
	def numberOfTourBooked
		EnziUIUtility.wait(@driver,:id,"enzi-data-table-container",@timeSettingMap['Wait']['Environment']['Lightening']['Max'])
		tourBookedtable = EnziUIUtility.selectChild(@driver,:id,"enzi-data-table-container",nil,"table")
		#puts tourBookedtable[0].find_elements(:tag_name,"tr").size
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
			#puts "Lead created => #{@@recordInsertedIds['Lead1']}"
		end
    	Salesforce.addRecordsToDelete(object,result.result.records[0].fetch('Id'))
		#puts "#{object} created => #{@@recordInsertedIds[object]}"
		result.result.records
	end
	def bookNewTour
		EnziUIUtility.wait(@driver,:class,"visible",@timeSettingMap['Wait']['Environment']['Lightening']['Min'])
    	#EnziUIUtility.wait(@driver,:class,"visible",@timeSettingMap['Wait']['Environment']['Lightening'])
		newButtonContainer = @driver.find_element(:class,"visible")
		EnziUIUtility.wait(@driver,:class,"lightningPrimitiveIcon",@timeSettingMap['Wait']['Environment']['Lightening']['Min'])
    	#EnziUIUtility.wait(@driver,:class,"lightningPrimitiveIcon",@timeSettingMap['Wait']['Environment']['Lightening'])
    	newButtonContainer.find_elements(:class,"lightningPrimitiveIcon")[0].click
	end
	def openPageForLead(id)
		#puts "opening page for id = #{id}"
		newUrl = @driver.current_url.split("?")[0]
		EnziUIUtility.navigateToUrl(@driver,"#{newUrl}?leadId=#{id}")
		#puts "navigated to #{@driver.current_url()}"
		newWindow = @driver.current_url();
    	EnziUIUtility.switchToWindow(@driver,newWindow)
	end
	def checkError(errorMessage)
		 @driver.find_elements(:class,"slds-theme--error")[0].text.eql? "#{errorMessage}"
		 EnziUIUtility.wait(@driver,:class,"slds-icon slds-icon--small",@timeSettingMap['Wait']['Environment']['Lightening']['Min'])
		 @driver.find_elements(:class,"slds-icon slds-icon--small")[0].click
  	end
  	def getData(onlySelected)
	    #puts "in GetDAta"
	    EnziUIUtility.wait(@driver, nil, nil, 10)
	    EnziUIUtility.wait(@driver, :id, "enzi-data-table-container", 100)
	    arrTable = @driver.find_elements(:id, 'enzi-data-table-container')
	    mapOfDataOnEachPage = nil
	    mapOfDataOnEachPageHashMap = Hash.new
	    arrTable.each do |table|
	      if table.attribute('tag_name') != 'table' then
	        mapOfDataOnEachPage = table
	      end
	    end
	    tBodyEle = mapOfDataOnEachPage.find_element(:tag_name, 'tbody')
	    arrRows = tBodyEle.find_elements(:tag_name, 'tr')
	    totalRows = tBodyEle.find_elements(:tag_name, 'tr').length
	    totalRows -= 1
	    rowCount = 0
	    if onlySelected == true then
	      arrRows.each do |row|
	        if rowCount == totalRows then
	          break
	        end
	        isRowSelected = @driver.find_element(:id, "checkbox:#{rowCount}").selected?
	        if isRowSelected == true then
	          arr = Array.new
	          row.find_elements(:tag_name, 'td').each do |col|
	            if col.text == "Select Row" then
	              arr.push(isRowSelected)
	            else
	              arr.push(col.text)
	            end
	          end
	          mapOfDataOnEachPageHashMap.store("#{rowCount}", arr)
	        end
	        rowCount = rowCount + 1
	      end
	    else
	      arrRows.each do |row|
	        if rowCount == totalRows then
	          break
	        end
	        isRowSelected = @driver.find_element(:id, "checkbox:#{rowCount}").selected?
	        arr = Array.new
	        row.find_elements(:tag_name, 'td').each do |col|
	          arr.push(col.text)
	        end
	        mapOfDataOnEachPageHashMap.store("#{rowCount}", arr)
	        rowCount = rowCount + 1
	      end
	    end
	    return mapOfDataOnEachPageHashMap
  	end
  	def getAllData(onlySelected)
	    pageNumber = 1
	    mapOfAllData = Hash.new
	    clickElement("btnFirst")
	    loop do
	      mapOfDataOnEachPage = getData(onlySelected)
	      if mapOfDataOnEachPage != nil then
	        mapOfAllData.store("#{pageNumber}",mapOfDataOnEachPage)
	      end
	      pageNumber += 1
	      EnziUIUtility.wait(@driver,nil,nil,5)
	      if(@driver.find_element(:id, "btnNext").enabled? == true)
	       #puts "btnNextEnability: #{@driver.find_element(:id, "btnNext").enabled?}"
	        clickElement("btnNext")
	      else
	        break
	      end
	    end
	    return mapOfAllData
  	end
	def rescheduleTour
		#lEnziUIUtility.wait(@driver,:id,"enzi-data-table-container",@timeSettingMap['Wait']['Environment']['Lightening']['Max'])
		@wait.until { @driver.find_element(:id ,"enzi-data-table-container").displayed? }
		EnziUIUtility.selectElement(@driver,"Reschedule","button")
		EnziUIUtility.wait(@driver,:id,"header43",@timeSettingMap['Wait']['Environment']['Lightening']['Min'])
		@wait.until { @driver.find_element(:id ,"StartTime").displayed? }
		EnziUIUtility.clickElement(@driver,:id,"StartTime")
		EnziUIUtility.selectChild(@driver,:id,"StartTime",nil,"option")[4].click
		EnziUIUtility.selectElement(@driver,"Save","button")
		#EnziUIUtility.wait(@driver,:id,"Reschedule",1000)
		@wait.until { @driver.find_element(:id ,"enzi-data-table-container").displayed? }
		#res.fetch('Status__c').eql?("Scheduled") && res.fetch('Original_Tour__c').eql?("#{@@recordInsertedIds['Tour_Outcome__c']['Id']}")
	end
	def tourStatusChecked?(statusToCheck,primaryMember)
    	@wait.until {!@driver.find_element(:id ,"spinner").displayed?}
		tourStatusChecked = false
		rescheduledTours = Salesforce.getRecords(@salesforceBulk,"Tour_Outcome__c","SELECT id,Status__c,Original_Tour__c FROM Tour_Outcome__c WHERE Primary_Member__r.email = '#{primaryMember}'",nil)
		#puts "tours :: #{rescheduledTours.inspect}"
    	rescheduledTours.result.records.each do |res|
			@@recordInsertedIds['Tour_Outcome__c1'] = res
			if res.fetch('Status__c').eql? "#{statusToCheck}" then
				tourStatusChecked = true
			end
		end
		return tourStatusChecked
	end
end

#Created By : Pragalbha Mahajan
#Created Date : 28/12/2017
#Modified date :

require 'enziUIUtility'
require 'salesforce'
require 'selenium-webdriver'
require 'yaml'
require 'json'
require 'date'

class ReservableAvailability

  @driver = nil
  @records = nil
  @recordsInJson = nil
  @@selected_buildings = Array.new

  def initialize(driver)
    @driver = driver
    #file = File.open("credentials.yaml", "r")
    file = File.open("E:/Projects/WeWork/SF-QA-Automation/Reservable Availability/TestData/Credentials.yaml", "r")
    mapCredentials = YAML.load(file.read())
    @driver.get "https://test.salesforce.com/login.jsp?pw=#{mapCredentials['password']}&un=#{mapCredentials['username']}"

    @salesforceBulk = Salesforce.login(mapCredentials['Staging']['username'], mapCredentials['Staging']['password'], true)

    EnziUIUtility.wait(@driver, :id, "phSearchInput", 100)
    #@driver.find_element(id: 'Contact_Tab').click
  end

  #Use: This function is used to get Driver
  def getDriver
    @driver
  end

=begin
	#Use: This function is used to create Contact
	def createContact
		contactRecordFile = File.open("E:/Projects/Training/Contact Availability/TestData/Test_ContactRecord.json", "r")
		contactRecordsInJson = contactRecordFile.read()
		contactRecords = JSON.parse(contactRecordsInJson)
		contact = contactRecords['contact']
		contact['AccountId'] = @@accountCreation[0]["Id"]
		#puts "contact is: #{contact}"
		contactArr = Array.new()
		contactArr.push(contact)
		@@contactCreation = Salesforce.createRecords(@salesforceBulk, 'Contact', contactArr)
		puts "Contact Id is#{@@contactCreation}"
		return @@contactCreation
	end

	#Use: This function is used to create Account
	def createAccount
		accountRecordsInJson = File.open("E:/Projects/Training/Contact Availability/TestData/Test_ContactRecord.json", "r").read()
		accountRecords = JSON.parse(accountRecordsInJson)
		accountArray = Array.new()
		accountArray.push(accountRecords['account'])
		
		@@accountCreation = Salesforce.createRecords(@salesforceBulk, 'Account', accountArray)
		puts "Account Id is#{@@accountCreation}"
		return @@accountCreation
	end
=end

  #Use: This fuction is used to delete test Records
  def recordDeletion
    Salesforce.deleteRecords(@salesforceBulk, 'Contact', @@contactCreation)
    Salesforce.deleteRecords(@salesforceBulk, 'Account', @@accountCreation)
  end

  #Use: This fuction is used to redirect to Contact Details Page
  def redirectToContactDetail
    url = @driver.current_url();
    #puts url
    newUrl = url.split('/003')
    #puts newUrl
    @driver.get "#{newUrl[0]}" + "/#{@@contactCreation[0]["Id"]}"
  end

  #Use: This fuction is used to redirect to Availability Page
  def redirectToAvailability
    EnziUIUtility.wait(@driver, :id, 'MoreTabs_Tab', 100)
    @driver.find_element(id: 'MoreTabs_Tab').click
    @driver.find_element(:link, 'Reservable').click
    #sleep(10)
  end

  def closePresetViewDialog()
    #Open create preset view dialog
    setAvailableFrom('2018-2-22')
    setCity('Austin')
    EnziUIUtility.clickElement(@driver, :id, 'btnSaveAsPresetView')
    EnziUIUtility.wait(@driver, nil, nil, 30)
    #Close Preset view dialog
    #@driver.find_elements(:tag_name, "button")
    EnziUIUtility.clickElement(@driver, :xpath, '/html/body/span/div/div[5]/div[1]/div/div[3]/button[2]')
    #selectElement(@driver,"Close","button")
    #@driver.find_elements(class:,"slds-button slds-button--brand")[7].click
    #@driver.find_elements(:class, "slds-button slds-button--brand").length
    #@driver.find_elements(:class, "slds-button slds-button--brand")[7].text
    #@driver.find_elements(:tag_name,"button").each do |button|
    #puts "Button attributes: #{button.attribute('class')}"
    #if button.attribute('class') == "slds-button slds-button--brand"

  end

  def closeSetPresetViewModal
    EnziUIUtility.clickElement(@driver, :xpath, '/html/body/span/div/div[5]/div[1]/div/div[3]/button[2]')
  end

  #Use: This fuction is used to set the Preset View in Availability Page
  def setPresetView(val)
    EnziUIUtility.wait(@driver, :id, 'presetViews', 100)
    EnziUIUtility.clickElement(@driver, :id, 'presetViews')
    EnziUIUtility.wait(@driver, nil, nil, 2)
    EnziUIUtility.selectOption(@driver, :id, 'presetViews', val)
    #puts "PresetViewValue: #{@driver.find_element(id: 'presetViews').attribute('text')}"
    #puts "val: #{val}"
    selectedOption = nil
    #Get all the options for this element
    all_options = @driver.find_elements(:tag_name, "option")
    #select the options
    all_options.each do |option|
      if option.text == val then
        selectedOption = option
        break
      end
    end
    if selectedOption.text == val
      return true
    else
      return false
    end
  end

  #Use: This fuction is used to create the Preset View in Availability Page
  def createPresetView(val)

    EnziUIUtility.clickElement(@driver, :id, 'btnSaveAsPresetView')
    EnziUIUtility.wait(@driver, :id, 'viewName', 5)
    EnziUIUtility.wait(@driver, nil, nil, 10)
    EnziUIUtility.setValue(@driver, :id, 'viewName', val)
    EnziUIUtility.wait(@driver, nil, nil, 5)

    #Save the preset view
    EnziUIUtility.clickElement(@driver, :id, 'save')
    EnziUIUtility.wait(@driver, nil, nil, 2)
    newOptionVal = nil

    dropdown_list = @driver.find_element(id: 'presetViews')
    options = dropdown_list.find_elements(tag_name: 'option')
    options.each do |option|
      if option.text == val
        newOptionVal = val
        break
      end
    end
    #puts "newOptionVal: #{newOptionVal}"
    return newOptionVal
  end

  #Use: This fuction is used to set the City in Availability Page
  def setCity(val)
    EnziUIUtility.wait(@driver, :id, 'city', 20)
    EnziUIUtility.clickElement(@driver, :id, 'city')
    EnziUIUtility.selectOption(@driver, :id, 'city', val)
    #EnziUIUtility.setValue(@driver,:value,'city',val)
  end

  #Use: This fuction is used to set Value to text box
  def setTextBoxValue(element_id, val)
    @driver.find_element(:id, element_id).clear()
    EnziUIUtility.setValue(@driver, :id, element_id, val)
  end

  #Use: This fuction is used to select Buildings
  def selectbuildings(arr_building_name)
    @wait = Selenium::WebDriver::Wait.new(:timeout => 2)
    arr_building_name.each do |building_name|
      @driver.find_element(:id, 'building').click
      @driver.find_element(:id, 'buildingcontainer').find_elements(:tag_name, 'li').each do |li_tag|
        if li_tag.text == building_name["name"]
          li_tag.click
          break
        end
      end
    end
    @driver.find_element(:tag_name, 'body').click
    #return AvailabilityPage.new(@driver)
  end

  def checkUnitType
    EnziUIUtility.wait(@driver, :id, "unitType", 60)
    @driver.find_element(:id, "unitType") #.click
    unitTypes = Salesforce.getRecords(@salesforceBulk, "Reservable__c", "SELECT Office_Work_Station_Type__c from Reservable__c")
    #puts "unitTypes.result.records[0]: #{unitTypes.result.records[0]}"
    #puts "unitTypes.result.records: #{unitTypes.result.records}"
    #puts "unitTypes.result.records Size: #{unitTypes.result.records.size}"
  end

  #Use: This fuction is used to set the unit type
  def setUnitType(arr_unit_type)
    arr_unit_type.each do |unit_type|
      @driver.find_element(:id, 'unitType').click
      @driver.find_element(:id, 'unitTypecontainer').find_elements(:tag_name, 'li').each do |li_tag|
        if li_tag.text == unit_type
          li_tag.click
          break
        end
      end
    end
  end

  #Use: This fuction is used to search Unit Type
  def searchUnitType(search_text)
    @driver.find_element(:id, 'unitType').click
    #@driver.find_element(:id,'unitType:txt').click
    EnziUIUtility.setValue(@driver, :id, 'unitType:txt', search_text)
  end

  #Use: This fuction is used to show Records
  def showRecords(val)
    #@@driver.find_element(:id ,'Show_Records__c').send_keys val
    EnziUIUtility.selectOption(@driver, :id, 'Show_Records__c', val)
    #return AvailabilityPage.new(@@driver)
  end

  #Use: This fuction is used to check wheather button is enabled or not
  def buttonEnabled?(buttonId)
    EnziUIUtility.wait(@driver, :id, "#{buttonId}", 30)
    buttonEnability = @driver.find_element(:id, "#{buttonId}").enabled?
    #puts "button Enability?: #{buttonEnability}"
    return buttonEnability
  end

  #Use:This function is use to set the available date
  def setAvailableFrom(date)
    EnziUIUtility.wait(@driver, :id, 'Available_From__c', 60)
    @driver.find_element(:name, 'Available_From__c').click
    arr_date = date.split('-')
    year_to_select = arr_date[0]
    @driver.find_element(:class, 'year').find_elements(:tag_name, "option").each do |option|
      if option.text == year_to_select
        option.click
        break
      end
    end

    next_button = nil
    prev_button = nil
    @driver.find_elements(:tag_name, 'button').each do |button|
      if button.attribute('title') == 'Next Month'
        next_button = button
      elsif button.attribute('title') == 'Previous Month'
        prev_button = button
      end
    end

    hash_month = {"January" => 1, "February" => 2, "March" => 3, "April" => 4, "May" => 5, "June" => 6, "July" => 7, "August" => 8, "September" => 9, "October" => 10, "November" => 11, "December" => 12}
    month_to_select = arr_date[1].to_i

    while true do
      if hash_month[@driver.find_element(:id, 'month').text] == month_to_select
        break
      elsif hash_month[@driver.find_element(:id, 'month').text] > month_to_select
        prev_button.click
      else
        next_button.click
      end
    end

    day_to_select = arr_date[2]
    @driver.find_element(:class, 'slds-datepicker__month').find_elements(:class, 'slds-day').each do |day|
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

  def clickToday()
    EnziUIUtility.wait(@driver, :id, 'Available_From__c', 50)
    availableFormElement = @driver.find_element(:name, 'Available_From__c')
    availableFormElement.click
    EnziUIUtility.clickElement(@driver, :link, "Today")
    #@driver.find_element(:link, 'Today').click
    #puts "availableFormElement Value: #{availableFormElement.attribute('value')}"
    d = DateTime.now
    #puts "#{d.strftime("%m/%d/%Y")}"
    if availableFormElement.attribute('value') == d.strftime("%m/%d/%Y")
      return true
    else
      return false
    end
  end

  def clickClear()
    availableFormElement = @driver.find_element(:name, 'Available_From__c')
    availableFormElement.click
    EnziUIUtility.clickElement(@driver, :link, "Clear")
    #@driver.find_element(:link, 'Clear').click
    #puts "availableFormElement Value: #{availableFormElement.attribute('value')}"
    if availableFormElement.attribute('value').empty?
      return true
    else
      return false
    end
  end

  def clickClose()
    availableFormElement = @driver.find_element(:name, 'Available_From__c')
    availableFormElement.click
    EnziUIUtility.clickElement(@driver, :link, "Close")
    #@driver.find_element(:link, 'Close').click
    if @driver.find_element(:id, 'Minimum_Capacity__c')
      return true
    else
      return false
    end
  end

  def checkShowRecord()
    key = 0
    recordMap = Hash.new
    recordMap = getData(false)
    loop do
      if recordMap["#{key}"][23] == "unoccupied"
        #puts "Inside if: #{recordMap["#{key}"][23]}"
        key += 6
        if key > 24
          key = 1
          break
        end
      else
        #puts "Inside else: #{recordMap["#{key}"][23]}"
        break
      end
    end
    #puts "Key: #{key}"
    if key == 1
      return true
    else
      return false
    end
  end

  def checkBuilding(city)
    setCity("#{city}")

    buildingsAsPerCity = Salesforce.getRecords(@salesforceBulk, "Building__c", "select id from Building__c where City__c = '#{city}'")
    #puts "buildingsAsPerCity: #{buildingsAsPerCity}"
    #puts "buildingsAsPerCity.result.records[0]: #{buildingsAsPerCity.result.records[0]}"
    #puts "buildingsAsPerCity.result.records: #{buildingsAsPerCity.result.records}"
    #puts "buildingsAsPerCity.result.records Size: #{buildingsAsPerCity.result.records.size}"
    EnziUIUtility.clickElement(@driver, :id, "building")
    #EnziUIUtility.clickElement(@driver,:id,"building:txt")
    cnt = 0
    #slds-lookup__list	#lookup-67
    @driver.find_elements(:id, "lookup-67")[1].find_elements(:tag_name, "ul").each do |option|
      #puts "Ul attributes: #{option.attribute('class')}"
      if option.attribute('class') == "slds-lookup__list"
        option.find_elements(:tag_name, "li").each do |list|
          #puts "list attributes: #{list.attribute('role')}"
          if list.attribute('role') == "presentation"
            cnt = cnt + 1
          end
        end
      end
    end
    if (cnt - 1) == buildingsAsPerCity.result.records.size
      return true
    else
      return false
    end
    #@driver.find_element(:class, "slds-lookup__list").find_elements(:tag_name,"li").each do|option|

    #puts "buildingsAsPerCity[0]['Id']: #{buildingsAsPerCity[0]['Id']}"
  end

  def isErrorInBuilding()
    EnziUIUtility.clickElement(@driver, :id, 'city')
    EnziUIUtility.selectOption(@driver, :id, "city", "Select City")
    EnziUIUtility.clickElement(@driver, :id, "building")
    @driver.find_elements(:tag_name, "div").each do |div|
      if div.attribute('class') == "slds-lookup__result-text slds-show"
        return true
      end
    end
    return false
  end


  #Use:This function is use to Reset the Form
  def resetForm(presetViewsOption = nil, cityOption = nil, minCapacity, maxCapacity, minPriceRange, maxPriceRange)
    if !presetViewsOption.eql?(nil) && !cityOption.eql?(nil) then

      EnziUIUtility.wait(@driver, :id, "presetViews", 30)
      EnziUIUtility.clickElement(@driver, :id, 'presetViews')
      EnziUIUtility.selectOption(@driver, :id, 'presetViews', presetViewsOption)
      sleep(5)
      #EnziUIUtility.wait(@driver,:id,"Available_From__c",30)
      EnziUIUtility.clickElement(@driver, :id, 'Available_From__c')
      element = @driver.find_element(:link, 'Clear')
      element.click
      #EnziUIUtility.clickElement(@driver,:id,'Available_From__c')
      #EnziUIUtility.selectOption(@driver,:id,'Available_From__c',availableFromOption)

      #EnziUIUtility.wait(@driver,:id,"city",30)
      EnziUIUtility.clickElement(@driver, :id, 'city')
      EnziUIUtility.selectOption(@driver, :id, 'city', cityOption)
    else
      #EnziUIUtility.wait(@driver,:id,"minCapacity",30)
      @driver.find_element(:id, minCapacity).clear()
      @driver.find_element(:id, maxCapacity).clear()
      @driver.find_element(:id, minPriceRange).clear()
      @driver.find_element(:id, maxPriceRange).clear()
    end
  end

  #Use:This function is click Button
  def clickButton(buttonId)
    EnziUIUtility.clickElement(@driver, :id, buttonId)
    sleep(10)
  end

  #Use:This function is used to get Building Units
  def getBuildingUnits
    arrTable = @driver.find_elements(:tag_name, 'table')
    availabilityTable = nil

    arrTable.each do |table|
      if table.attribute('class') == 'slds-table slds-table--bordered slds-max-medium-table--stacked-horizontal'
        availabilityTable = table
        break
      end
    end
    #puts "availabilityTable: #{availabilityTable}"
    #puts "availabilityTable Class: #{availabilityTable.attribute('class')}"
    tBodyEle = availabilityTable.find_element(:tag_name, 'tbody')
    #puts "tBodyEle: #{tBodyEle}"
    #puts "tBodyEle: "
    arrRows = tBodyEle.find_elements(:tag_name, 'tr')
    #puts "arrRows: #{arrRows}"
    arrBuildingUnit = Array.new
    arrRows.each do |row|
      #puts "Row class: #{row.attribute('class')}"
      row.find_elements(:tag_name, 'td').each do |col|
        #puts "col class: #{col.attribute('class')}"
        #puts "col data-label: #{col.attribute('data-label')}"
        if (col.attribute('data-label') == 'Unit')
          #puts "Column data lable: #{col.attribute('data-label')}"
          arrBuildingUnit.push(col.find_element(:class, 'slds-truncate').text)  #modified on 21 feb
        end
      end
    end
    puts "arrBuildingUnit: #{arrBuildingUnit}"
    return arrBuildingUnit
  end

  #Use:This function is used to determine Error is enaled or Not
  def checkError(field)
    parentElements = @driver.find_elements(:xpath, "//input[@id = '#{field}']/ancestor::div[@class = 'slds-form-element slds-has-error cEnziField']")

    #puts "parentElements: #{parentElements}"
    if parentElements.empty? == false
      puts "parentElements isDisplayed: #{parentElements[0].displayed?}"
      if parentElements[0].displayed? == true
        return true
      else
        return false
      end
    else
      return false
    end
  end

  def checkPattern(city, pattern)
    setCity("#{city}")
    EnziUIUtility.clickElement(@driver, :id, "building")
    EnziUIUtility.clickElement(@driver, :id, "building:txt")
    EnziUIUtility.setValue(@driver, :id, "building:txt", pattern)
    buildingsPatternAsPerCity = Salesforce.getRecords(@salesforceBulk, "Building__c", "SELECT id,name from Building__c WHERE name like '%#{pattern}%' and city__c = '#{city}'")
    #puts "buildingsPatternAsPerCity records: #{buildingsPatternAsPerCity.result.records}"
    #puts "buildingsPatternAsPerCity records: #{buildingsPatternAsPerCity.result.records[0]}"
    #puts "buildingsPatternAsPerCity records size: #{buildingsPatternAsPerCity.result.records.size}"
    cnt = 0
    @driver.find_elements(:class, "slds-lookup__list")[1].find_elements(:tag_name, "li").each do |list|
      #puts "list role:#{list.attribute('role')}"
      if list.attribute('role') == "presentation"
        cnt = cnt + 1
      end
    end
    #puts "Count: #{cnt}"
    if (cnt - 1) == buildingsPatternAsPerCity.result.records.size
      return true
    else
      return false
    end
  end

  #Use:This function is used to select Reservables
  def selectReservables(val)
    #puts "Val is: #{val}"
    arrTable = @driver.find_elements(:tag_name, 'table')
    availabilityTable = nil
    arrTable.each do |table|
      if table.attribute('class') == 'slds-table slds-table--bordered slds-max-medium-table--stacked-horizontal'
        availabilityTable = table
        break
      end
    end
    #puts "availabilityTable: #{availabilityTable}"
    #puts "availabilityTable class: #{availabilityTable.attribute('class')}"
    #puts "availabilityTable size: #{availabilityTable.size}"
    tBodyEle = availabilityTable.find_element(:tag_name, 'tbody')

    arrRows = tBodyEle.find_elements(:tag_name, 'tr')
    #puts "arrRows size #{arrRows.size}"
    index = -1
    arrRows.each do |row|
      #puts "row class: #{row.attribute('class')}"
      row.find_elements(:tag_name, 'td').each do |col|
        #puts "Column data lable: #{col.attribute('data-label')}"
        if (col.attribute('data-label') == 'Unit')
          index = index + 1
          if (col.find_element(:class, 'slds-truncate').text == val)
            #puts "Clicking on Checkbox, Index is: #{index}"
            row.find_element(:id, "checkbox-span:#{index}").click
            @@selected_buildings.push(val)
            break
          end
        end
      end
      #index = index + 1
    end
    #puts "selected_buildings: #{@@selected_buildings}"
    @wait = Selenium::WebDriver::Wait.new(:timeout => 20)
    #return AvailabilityPage.new(@@driver)
  end

  def checkPendingContracts()
    parentKey = 0
    key = 0
    recordMap = Hash.new
    recordMap = getData(false)
    loop do
      if recordMap["#{parentKey}"]["#{key}"][24] == "None" || recordMap["#{parentKey}"]["#{key}"][24] == "Contract Voided"
        #puts "Inside if: #{recordMap["#{key}"][23]}"
        parentKey += 1
        key += 6
        if key > 24 || parentKey > 3
          key = 1
          parentKey = 1
          break
        end
      else
        #puts "Inside else: #{recordMap["#{parentKey}"]["#{key}"][24]}"
        break
      end
    end
    #puts "Key: #{key}"
    if key == 1
      return true
    else
      return false
    end
  end

=begin
	    arrRows = tBodyEle.find_elements(:tag_name,'tr')
	    arrRows.each_with_index do |row,index|
	    	puts "Index: #{index}"
	    	puts "row class: #{row.attribute('class')}"
		    row.find_elements(:tag_name,'td').each do |col|
		    	puts "Column data lable: #{col.attribute('data-label')}"
		        if(col.attribute('data-label')=='Unit')
		          	if(col.find_element(:class,'uiOutputText').text==val)
		          		puts "Clicking on Checkbox, Index is: #{index}"
			            row.find_element(:id,"checkbox-span:#{index}").click	           
			            @@selected_buildings.push(val)
			            break
		        	end
		        end
		    end
	    end
=end


  def selectElement(textToselect, elementTosearch)
    all_Elements = @driver.find_elements(:tag_name, "#{elementTosearch}")
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

  def clickElement(id)
    begin
      #sleep for 5 sec to load page
      EnziUIUtility.wait(@driver, nil, nil, 5)
      #wait untill element found
      EnziUIUtility.wait(@driver, :id, id, 50)
      #click on element
      EnziUIUtility.clickElement(@driver, :id, id)
      return true
    rescue
      return false
    end
  end

  def unitTypeError(val)
    EnziUIUtility.clickElement(@driver, :id, 'unitType')
    EnziUIUtility.clickElement(@driver, :id, "unitType:txt")
    EnziUIUtility.setValue(@driver, :id, "unitType:txt", val)
    unitTypeContainer = @driver.find_element(:id, "unitTypecontainer")
    unitTypeContainer.find_elements(:tag_name, "div").each do |div|
      if div.attribute('class') == "slds-lookup__result-text slds-show"
        return true
      end
    end
    return false
  end

  def checkSendProposalTableUnits()

    #puts 'Selected Building==>', @@selected_buildings
    unitsFlag = true

    EnziUIUtility.switchToWindow(@driver, "Export Reservable")
=begin
	    @driver.window_handles.each do |window|
	      if window != @@mainWindow && window != @newWindow then
	        @driver.switch_to.window window
	      end
	    end
=end
    EnziUIUtility.wait(@driver, :id, 'reservableTable', 10)
    tblElement = @driver.find_element(:id, 'reservableTable')
    rows = tblElement.find_elements(:tag_name, 'tr')
    heads = tblElement.find_elements(:tag_name, 'th')
    ind = nil
    heads.each_with_index do |head, index|
      #puts head.text
      if head.text == 'Unit' then
        ind = index
      end
    end

    cols = nil
    rows.each do |row|
      cols = row.find_elements(:tag_name, 'td')
      puts cols.count
      cols.each_with_index do |col, colIndex|
        if colIndex === ind then
          #puts cols[colIndex].text
          #puts @@selected_buildings.index(cols[colIndex].text)

          if @@selected_buildings.index(cols[colIndex].text) == nil then
            unitsFlag = false
            break
          end
        end # end of colIndex if
      end # end of cols loop
      if (!unitsFlag) then
        break
      end
    end #end of rows loop
    puts @driver.title

    if unitsFlag then
      return true
    else
      return nil
    end
  end

  def getHeaders
    EnziUIUtility.wait(@driver, nil, nil, 60)
    #EnziUIUtility.wait(@driver,:id,"enzi-data-table-container",100)

    arrTable = @driver.find_elements(:tag_name, 'table')
    availabilityTable = nil

    mapOfDataOnEachPage = nil
    arrTable.each do |table|
      if table.attribute('class') == 'slds-table slds-table--bordered slds-max-medium-table--stacked-horizontal'
        mapOfDataOnEachPage = table
        break
      end
    end
    #puts "mapOfDataOnEachPage #{mapOfDataOnEachPage}"

    tHeadEle = mapOfDataOnEachPage.find_element(:tag_name, 'thead')
    rowOfHeaders = tHeadEle.find_elements(:tag_name, 'tr')
    arrHeaders = Array.new
    #puts rowOfHeaders.length
    #puts rowOfHeaders[0].find_elements(:tag_name,'th').length
    rowOfHeaders.each do |row|
      #puts "row found"
      row.find_elements(:tag_name, 'th').each do |col|
        #puts "col found"
        #puts "111"+col.text
        if col.text.include?("Sort") == true
          header = col.text
          header = header.delete("\n")
          header = header.split("Sort")[1]
          #puts "111111111111111111"+header
          arrHeaders.push(header.chomp)
        else
          #puts "222222222222222222"+col.text
          arrHeaders.push(col.text.chomp)
        end
      end
    end #end of rowOfHeaders.each
    #puts "1111111#{arrHeaders}"
    #puts "2222222#{arrHeaders[0]}"
    #puts "333333#{arrHeaders}"
    #puts "1111111#{arrHeaders[2]}"
    puts "arrHeaders#{arrHeaders}"
    puts "arrHeaders 1st element: #{arrHeaders[1]}"
    return arrHeaders
  end

  def getAllData(onlySelected)
    #totalRowCount = 0
    pageNumber = 1
    mapOfAllData = Hash.new
    #@driver.find_element(:id,"btnFirst").click
    clickElement("btnFirst")
    loop do
      mapOfDataOnEachPage = getData(onlySelected)
      #puts mapOfDataOnEachPage
      #totalRowCount += rowCount
      #puts rowCount
      #puts totalRowCount
      #puts pageNumber
      if mapOfDataOnEachPage != nil then
        mapOfAllData.store("#{pageNumber}", mapOfDataOnEachPage)
      end
      #puts mapOfAllData
      puts "pageNumber:#{pageNumber}"
      pageNumber += 1
      EnziUIUtility.wait(@driver, nil, nil, 5)
      if (@driver.find_element(:id, "btnNext").enabled? == true)
        puts "btnNextEnability: #{@driver.find_element(:id, "btnNext").enabled?}"
        clickElement("btnNext")
      else
        break
      end
      #break if clickElement("btnNext") == false
    end
    puts "mapOfAllData: #{mapOfAllData}"
    return mapOfAllData
  end

  def getData(onlySelected)
    EnziUIUtility.wait(@driver, nil, nil, 20)
    arrTable = @driver.find_elements(:tag_name, 'table')
    availabilityTable = nil

    mapOfDataOnEachPage = nil
    mapOfDataOnEachPageHashMap = Hash.new
    arrTable.each do |table|
      if table.attribute('class') == 'slds-table slds-table--bordered slds-max-medium-table--stacked-horizontal'
        mapOfDataOnEachPage = table
        break
      end
    end
    puts "mapOfDataOnEachPage: #{mapOfDataOnEachPage.attribute('class')}"
    tBodyEle = mapOfDataOnEachPage.find_element(:tag_name, 'tbody')
    arrRows = tBodyEle.find_elements(:tag_name, 'tr')
    puts "arrRows: #{arrRows}"
    totalRows = tBodyEle.find_elements(:tag_name, 'tr').length
    puts "totalRows: #{totalRows}"
    totalRows -= 1
    rowCount = 0
    if onlySelected == true then
      arrRows.each do |row|
        puts "in selected row"
        puts "checkbox:#{rowCount}"
        puts "rowCount:#{rowCount}"
        puts "totalRows:#{totalRows}"
        if rowCount == totalRows then
          break
        end
        isRowSelected = @driver.find_element(:id, "checkbox-span:#{rowCount}").selected?
        if isRowSelected == true then
          arr = Array.new
          row.find_elements(:tag_name, 'td').each do |col|
            puts "col"
            if col.text == "Select Row" then
              puts col.text
              arr.push(isRowSelected)
            else
              #puts col.text
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
        #isRowSelected= @driver.find_element(:id,"checkbox-span:#{rowCount}").selected?
        #puts "row"
        arr = Array.new
        row.find_elements(:tag_name, 'td').each do |col|
          puts "col"
          puts col.text
          arr.push(col.text)
        end
        puts "arr#{arr}"
        mapOfDataOnEachPageHashMap.store("#{rowCount}", arr)
        rowCount = rowCount + 1
      end

    end
    puts "rowCount: #{rowCount}"
    puts "arrRows: #{arrRows}"
    puts "mapOfDataOnEachPageHashMap length : #{mapOfDataOnEachPageHashMap.length}"
    puts "mapOfDataOnEachPageHashMap data: #{mapOfDataOnEachPageHashMap}"
    puts "mapOfDataOnEachPageHashMap first row data: #{mapOfDataOnEachPageHashMap['0']}"
    puts "mapOfDataOnEachPageHashMap first row Availability: #{mapOfDataOnEachPageHashMap['0'][23]}"

    return mapOfDataOnEachPageHashMap
  end

  def calculateNumberOfRows
    #allData=Hash.new
    allData = getAllData(false)
    pageNumber = "1"
    totalRowCount = 0
    loop do
      pageNumber = pageNumber.to_s
      rowCount = allData["#{pageNumber}"].length
      #puts "row count"
      #puts rowCount
      totalRowCount += rowCount
      pageNumber = pageNumber.to_i
      #puts "page number"
      #puts pageNumber
      #puts "all data length"
      #puts allData.length
      pageNumber += 1
      #puts rowCount
      #puts "totalRowCount"
      #puts totalRowCount
      break if pageNumber > allData.length
    end
    return totalRowCount
  end
end

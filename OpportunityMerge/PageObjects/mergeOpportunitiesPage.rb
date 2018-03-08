#Created By : Kishor Shinde
#Created Date : 28/12/2017
#Modified date :
require 'enziUIUtility'
require 'salesforce'
require 'selenium-webdriver'
require 'yaml'
require 'json'

class MergeOpportunities
  @driver = nil
  @recordToDelete = nil
  @sfBulk = nil
  @sObjectRecords = nil
  @mapCredentials = nil
  @testData = nil

  #read username and password from credentials.yaml file and logged in
  #go to home page and then MergeOpportunitiesPage
  def initialize(driver)
    @driver = driver
    @testData = Hash.new
    file = File.open("../../credentials.yaml", "r")
    @mapCredentials = YAML.load(file.read())

    sObjectRecordsJson = File.read("../TestData/testRecords.json")
    @sObjectRecords = JSON.parse(sObjectRecordsJson)
    @sfBulk = Salesforce.login(@mapCredentials['QAAuto']['username'],@mapCredentials['QAAuto']['password'],true)
    @driver.get "https://test.salesforce.com/login.jsp?pw=#{@mapCredentials['QAAuto']['password']}&un=#{@mapCredentials['QAAuto']['username']}"
    #url = driver.current_url();
    #newUrl = url.split('/home')
    #@driver.get "#{newUrl[0]}"+"/apex/MergeOpportunitiesPage"
  end

  def setUser(userNumber)
    userName = @mapCredentials["username#{userNumber}"]
    password = @mapCredentials["password#{userNumber}"]
    @driver.get "https://test.salesforce.com/login.jsp?pw=#{password}&un=#{userName}"
  end

  def createTestData()
    #userName = @mapCredentials["username#{userNumber}"]
    #password = @mapCredentials["password#{userNumber}"]
    @sfBulk = Salesforce.login(@mapCredentials['QAAuto']['username'], @mapCredentials['QAAuto']['password'], true)
    #@recordToDelete = Hash.new
    accountId = Salesforce.createRecords(@sfBulk, "Account", @sObjectRecords['MergeOpportunitiesPage']['Account'])
    #accArr = Array.new
    #accArr.push(accountId[0].fetch("Id"))
    #accArr.push(accountId[1].fetch("Id"))
    #@testData.store("account", accArr)
    puts "Account created"
    puts accountId.inspect
=begin
    puts accountId[0].fetch("Id")
    puts accountId[1].fetch("Id")
=end

    contactJSON = @sObjectRecords['MergeOpportunitiesPage']['Contact']
    contactJSON[0]["AccountId"] = accountId[0].fetch("Id")
    #contactJSON[1]["AccountId"] = accountId[1].fetch("Id")
    contactId = Salesforce.createRecords(@sfBulk, "Contact", contactJSON)
    puts "contact created"
    puts contactId[0].fetch("Id")
    #puts contactId[1].fetch("Id")

    buildingIds = Salesforce.createRecords(@sfBulk, "Building__c", @sObjectRecords['MergeOpportunitiesPage']['Building__c'])
    puts "Building__c created"
    puts buildingIds[0].fetch("Id")
    #puts buildingIds[1].fetch("Id")

=begin
    journeyJSON = @sObjectRecords['MergeOpportunitiesPage']['Journey']
    journeyJSON[0]["Primary_Contact__c"] = contactId[0].fetch("Id")
    journeyJSON[1]["Primary_Contact__c"] = contactId[1].fetch("Id")
    journeyIds = Salesforce.createRecords(@sfBulk, "Journey__c", journeyJSON)
    puts "Journey created"
    puts journeyIds[0].fetch("Id")
    puts journeyIds[1].fetch("Id")
=end


    opportunityJSON = @sObjectRecords['MergeOpportunitiesPage']['Opportunity']
    #if isAllAccess == true then
      opportunityJSON[0]["AccountId"] = accountId[0].fetch("Id")
    #else
      #opportunityJSON[0]["AccountId"] = @testData["account"][0]
    #end
    opportunityJSON[0]["Building__c"] = buildingIds[0].fetch("Id")
    opportunityJSON[0]["Primary_Member__c"] = contactId[0].fetch("Id")
    #opportunityJSON[1]["AccountId"] = accountId[1].fetch("Id")
    #opportunityJSON[1]["Building__c"] = buildingIds[1].fetch("Id")
    #opportunityJSON[1]["Primary_Member__c"] = contactId[1].fetch("Id")
    opportunityIds = Salesforce.createRecords(@sfBulk, "Opportunity", opportunityJSON)
    puts "Opportunity created"
    puts opportunityIds[0].fetch("Id")
    #puts opportunityIds[1].fetch("Id")

=begin
    tourJSON = @sObjectRecords['MergeOpportunitiesPage']['Tour']
    tourJSON[0]["Opportunity__c"] = opportunityIds[0].fetch("Id")
    tourJSON[0]["Journey__c"] = journeyIds[0].fetch("Id")
    tourJSON[0]["Location__c"] = buildingIds[0].fetch("Id")
    tourJSON[1]["Opportunity__c"] = opportunityIds[1].fetch("Id")
    tourJSON[1]["Journey__c"] = journeyIds[1].fetch("Id")
    tourJSON[1]["Location__c"] = buildingIds[1].fetch("Id")
    tourIds = Salesforce.createRecords(@sfBulk, "Tour_Outcome__c", tourJSON)
    puts "Tour created"
    puts tourIds[0].fetch("Id")
    puts tourIds[1].fetch("Id")
=end
  end

  #delete created records
  def deleteCreatedRecord
    puts "Record To delete"
    puts @testData["account"]
    Salesforce.deleteRecords(@sfBulk, "Account", @testData["account"])
    puts "Account deleted"
    #Salesforce.deleteRecords(@sfBulk,"Opportunity",@recordToDelete["contact"])
    #Salesforce.deleteRecords(@sfBulk,"Opportunity",@recordToDelete["account"])
  end

  #get current page url
  def getDriver
    @driver
  end

  def getTab(tabId, btnText)
    #puts "Clicking on tab"
    EnziUIUtility.wait(@driver, :id, tabId, 30)
    @driver.find_element(:id, tabId).click
    EnziUIUtility.wait(@driver, :class, "fBody", 5)
    #puts "clicking on go!"
    span = @driver.find_element(:class, "fBody")
    span.find_element(:tag_name, "input").click
    EnziUIUtility.wait(@driver, :tag_name, "input", 10)
    #puts "Clicking on your button"
    child = @driver.find_elements(:tag_name, "input")
    child.each do |option|
      if option.attribute("value") == "#{btnText}" then
        return option
        break
      end
    end
  end

  def checkBtnEnabled(id)
    EnziUIUtility.wait(@driver, :id, id, 30)
    return @driver.find_element(:id, id).enabled?
  end

  def getHeader
    #wait untill element found
    EnziUIUtility.wait(@driver, :tag_name, "h3", 60)
    return @driver.find_element(:tag_name, "h3").text
  end

  def getProgress
    #wait untill element found
    EnziUIUtility.wait(@driver, :class, "slds-wizard__progress-bar", 60)
    progressBar = @driver.find_elements(:class, "slds-wizard__progress-bar")
    percentage = progressBar[0].attribute("style").split(' ')[1].chomp(';')
    return percentage
  end

  def calculateNumberOfRows(onlySelected)
    #EnziUIUtility.wait(@driver,nil,nil,3)
    puts "in calculateNumberOfRows"
    allData = getAllData(onlySelected)
    pageNumber = "1"
    totalRowCount = 0
    loop do
      pageNumber = pageNumber.to_s
      rowCount = allData["#{pageNumber}"].length
      totalRowCount += rowCount
      pageNumber = pageNumber.to_i
      pageNumber += 1
      break if pageNumber > allData.length
    end
    return totalRowCount
  end

  def getSelectedValue(parentfindBy, parentElementId, childFindBy, childIdentifier)
    #sleep for 5 sec to load page
    EnziUIUtility.wait(@driver, nil, nil, 5)
    #wait untill element found
    EnziUIUtility.wait(@driver, :id, parentElementId, 50)
    #Get the select element
    select = @driver.find_element(parentfindBy, parentElementId)
    #Get all the options for this element
    all_options = select.find_elements(childFindBy, childIdentifier)
    #puts all_options[0].class
    #puts all_options[0].text
    return all_options[0].text.to_i
    #select the options
    #all_options.each do |option|
    #if option.attribute("selected") == "selected" then
    #puts option.text.class
    #puts option.text
    #return option.text.to_i
    #end
    #end
  end

  def calulateNumberOfPagesAccordingToRecordInSalesforce(pattern)
    numberOfPages = nil
    pageSize = getSelectedValue(:id, "selectPageSize", :tag_name, "option")
    numberOfOpprtunities = NumberOfOpportunitiesInSalesforce(pattern)
    numberOfPages = (numberOfOpprtunities / pageSize.to_i)
    if numberOfOpprtunities % pageSize.to_i != 0 then
      numberOfPages += 1
    end
    return numberOfPages
  end

  #get number of opportunities from salesforce having stage != merged and name like pattern given by user
  def numberOfOpportunitiesInSalesforce(pattern = nil)
    #user = "@mapCredentials['username" + userNumber + "']"
    count = 0
    opportunityIds = nil
    profile = Salesforce.getRecords(@sfBulk, "User", "select Name,Profile.Name from User where Username = '#{@mapCredentials['QAAuto']['username']}'").result.records[0]
    if (profile['Profile.Name'] == 'WeWork System Administrator' || profile['Profile.Name'] == 'WeWork Support and Operations') then
      if pattern != nil then
        opportunityIds = Salesforce.getRecords(@sfBulk, "Opportunity", "SELECT Id FROM Opportunity WHERE Name like '%#{pattern}%' and StageName != 'Merged'")
      else
        opportunityIds = Salesforce.getRecords(@sfBulk, "Opportunity", "SELECT Id FROM Opportunity WHERE StageName != 'Merged'")
      end
      if opportunityIds.result.records[0] != nil then
        opportunityIds.result.records.each {count = count + 1}
        return count
      else
        return count
      end
    else
      if pattern != nil then
        opportunityIds = Salesforce.getRecords(@sfBulk, "Opportunity", "SELECT Id FROM Opportunity WHERE Name like '%#{pattern}%' and StageName != 'Merged' and StageName != 'Closed Won' and StageName != 'Closed Lost' and Owner.UserName = '#{user}'")
      else
        opportunityIds = Salesforce.getRecords(@sfBulk, "Opportunity", "SELECT Id FROM Opportunity WHERE StageName != 'Merged' and Owner.UserName = '#{user}'")
      end
      if opportunityIds.result.records[0] != nil then
        opportunityIds.result.records.each {count = count + 1}
        return count
      else
        return count
      end
    end

  end

  #get Array of childs
  def getSelectOptions(parentfindBy, parentElementId, childFindBy, childIdentifier)
    #EnziUIUtility.wait(@driver,nil,nil,5)
    #wait untill element found
    EnziUIUtility.wait(@driver, :id, parentElementId, 30)

    count = 0
    array = Array.new()
    #Get the parent element
    parent = @driver.find_element(parentfindBy, parentElementId)
    #Get all the options for this element
    all_options = parent.find_elements(childFindBy, childIdentifier)
    #push child in array
    all_options.each do |option|
      if option.tag_name == childIdentifier then
        array.push(option.text)
      end
    end
    return array
  end

  #Use: This function is Used to get element
  # e.g. getElementByAttribute(:elementFindBy,"elementIdentity","attributeName","attributeValue")
  def getElementByAttribute(elementFindBy,elementIdentity,attributeName,attributeValue)
    puts "in getElementByAttribute"
    elements = @driver.find_elements(elementFindBy, elementIdentity)
    elements.each do |element|
      if element.attribute(attributeName) != nil then
        if element.attribute(attributeName).include? attributeValue then
            return element
            break
        end
      end
    end
  end

  def clickElement(id)
    begin
      #sleep for 5 sec to load page
      #EnziUIUtility.wait(@driver, nil, nil, 20)
      #wait untill element found
      EnziUIUtility.wait(@driver, :id, id, 50)

      #@driver.find_element(:id ,id).doubleClick().build().perform()
      EnziUIUtility.clickElement(@driver, :id, id)
      #@driver.action.click(@driver.find_element(:id ,id)).perform
      return true
    rescue Exception => e
      puts e
      #@driver.find_element(:id ,id).click.perform
      return false
    end
  end

  def clickNextWithoutSelectingOpportunity
    #clickElement("next")
    #sleep for 5 sec to load error message
    EnziUIUtility.wait(@driver, nil, nil, 5)
    #get error div using parent element id
    #strExpectedMsg = EnziUIUtility.selectChildByText(@driver, :id, 'lightning', :tag_name, 'h2', 'Select atleast two opportunities.')
    EnziUIUtility.wait(@driver, nil, nil, 10)
    #return error message
    return strExpectedMsg
  end

  def clickNextBySelectingOpportunity
    #clickElement("checkbox:0")
    #clickElement("next")
    #get error div using parent element id
    #strExpectedMsg = EnziUIUtility.selectChildByText(@driver, :id, 'lightning', :tag_name, 'h2', 'Select atleast two opportunities.')
    #return error message
    #return strExpectedMsg
    return getErrorMessage(:id,"divErrorToaster")
  end

  def isSelected(id)
    return @driver.find_element(:id, id).selected?
  end

  def clickMergeBySelectingTwoOpportunityAsPrimaryOpportunity
    #clickElement("checkbox:0")
    #clickElement("checkbox:1")
    #puts getElementByAttribute(:tag_name,"button","id","next").click
    #get error div using parent element id
    #strExpectedMsg = EnziUIUtility.selectChildByText(@driver, :id, 'lightning', :tag_name, 'h2', 'You can select only one opportunity as primary opportunity to merge.')
    #return error message
    #return strExpectedMsg
    return getErrorMessage(:id,"divErrorToaster")
  end


  def clickMergeWithoutSelectingOpportunityAsPrimaryOpportunity()
    EnziUIUtility.wait(@driver, nil, nil, 3)
    #clickElement("next")
    getElementByAttribute(:tag_name,"button","id","next").click
    return getErrorMessage(:id,"divErrorToaster")
    #return EnziUIUtility.selectChildByText(@driver, :id, 'lightning', :tag_name, 'h2', 'Please select one opportunity as primary opportunity to merge.')
  end

  def getErrorMessage(findBy, elementIdentifier)
    wait = Selenium::WebDriver::Wait.new(:timeout => 60);
    wait.until {@driver.find_element(findBy, elementIdentifier).displayed?}
    if @driver.find_element(findBy, elementIdentifier).displayed? then
      return @driver.find_element(findBy, elementIdentifier).text.split("\n")[1]
    end

    #return EnziUIUtility.selectChildByText(@driver,parentfindBy,parentElementIdentifier,childFindBy,childIdentifier,textToselect)
  end

  def getTableHeaders
    EnziUIUtility.wait(@driver, nil, nil, 10)
    EnziUIUtility.wait(@driver, :id, "enzi-data-table-container", 100)
    arrTable = @driver.find_elements(:id, 'enzi-data-table-container')
    mapOfDataOnEachPage = nil
    arrTable.each do |table|
      if table.attribute('tag_name') != 'table' then
        mapOfDataOnEachPage = table
      end
    end
    tHeadEle = mapOfDataOnEachPage.find_element(:tag_name, 'thead')
    rowOfHeaders = tHeadEle.find_elements(:tag_name, 'tr')
    arrHeaders = Array.new
    rowOfHeaders.each do |row|
      row.find_elements(:tag_name, 'th').each do |col|
        if col.text.include?("Sort") == true
          header = col.text
          header = header.delete("\n")
          header = header.split("Sort")[1]
          arrHeaders.push(header.chomp)
        else
          arrHeaders.push(col.text.chomp)
        end
      end
    end
    return arrHeaders
  end

  def getAllData(onlySelected)
    puts "in getAllData"
    pageNumber = 1
    mapOfAllData = Hash.new
    clickElement("btnFirst")
    loop do
      mapOfDataOnEachPage = getData(onlySelected)
      puts mapOfDataOnEachPage
      if mapOfDataOnEachPage != nil then
        #puts "#{pageNumber}"
        mapOfAllData.store("#{pageNumber}", mapOfDataOnEachPage)
      end
      pageNumber += 1
      if checkBtnEnabled('btnNext') == true then
        clickElement("btnNext")
      else
        break
      end
    end
    clickElement("btnFirst")
    return mapOfAllData
  end

  def getData(onlySelected)
    puts "in GetDAta"
    #EnziUIUtility.wait(@driver, nil, nil, 10)
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


  def isOpportunityMerged(id)
    opportunity = Salesforce.getRecords(@sfBulk, "Opportunity", "select Id,Locations_Interested__c,Merged_On__c,Merged_Opprtunity__c,StageName from Opportunity where Id='#{id}'")

    #locations = opportunity.result.records[0].fetch("Locations_Interested__c").chomp(';').split(";")
    #puts locations.length
    #tours = Salesforce.getRecords(@sfBulk, "Tour_Outcome__c", "select Id,Opportunity__c from Tour_Outcome__c where Opportunity__c = '#{id}'")
    #numOfTours = tours.result.records.length
    return opportunity.result.records[0]
  end


  def closeErrorMessage
    #puts "Sleep for 5 sec"
    #EnziUIUtility.wait(@driver,nil,nil,5)
    wait = Selenium::WebDriver::Wait.new(:timeout => 30);
    wait.until {@driver.find_element(:id, "divErrorToaster:btnClose").displayed?}
    if @driver.find_element(:id, "divErrorToaster:btnClose").displayed? then
      #clickElement("divErrorToaster:btnClose")
      puts "error message displayed"
      getElementByAttribute(:tag_name,"button","id","divErrorToaster:btnClose").click
    end
  end

  def searchText(val)
    EnziUIUtility.wait(@driver, :id, "searchBox", 30)
    @driver.find_element(:id, "searchBox").clear()
    EnziUIUtility.setValue(@driver, :id, "searchBox", val)
    #EnziUIUtility.wait(@driver, nil, nil, 5)
  end

  def getConfirmationMessage
    EnziUIUtility.wait(@driver, :class, "slds-modal__container", 100)
    EnziUIUtility.wait(@driver, :class, "slds-modal__header", 100)
    EnziUIUtility.wait(@driver, :class, "slds-modal__footer ", 100)
    modal = @driver.find_element(:class, "slds-modal__container")
    message = modal.text.split("\n")[2]
    return message
  end

  def selectChildBy(parentfindBy, parentElementIdentifier, childFindBy, childIdentifier, textToselect)
    #puts "in selectChildBy"
    #puts EnziUIUtility.selectChildByText(@driver,:class,"slds-modal slds-fade-in-open",:tag_name,"button","Yes")
    EnziUIUtility.wait(@driver, parentfindBy, "slds-modal__container", 100)
    EnziUIUtility.wait(@driver, parentfindBy, "slds-modal__header", 100)
    EnziUIUtility.wait(@driver, parentfindBy, "slds-modal__footer ", 100)
    modal = @driver.find_element(parentfindBy, parentElementIdentifier)
    buttons = modal.find_elements(childFindBy, childIdentifier)
    buttons.each do |child|
      if child.text == textToselect then
        #puts "text found"
        #puts child.text
        childText = child.text
        child.click
        break
      end
    end
  end
end
#object = MergeOpportunities.new(Selenium::WebDriver.for :firefox)
#object.createTestData
=begin
object = MergeOpportunities.new(Selenium::WebDriver.for :firefox)
object.clickOnTab("Opportunity_Tab","Opportunity Merge").click
object.searchText('test_enzi')
EnziUIUtility.wait(nil,nil,nil, 30)
#puts object.numberOfOpportunitiesInSalesforce
puts  object.calculateNumberOfRows(false)
=end

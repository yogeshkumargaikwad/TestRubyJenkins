#Created By : Monika Pingale
#Created Date : 28/12/2017
#Modified date : 31/01/2018
require_relative File.expand_path(Dir.pwd + '/GemUtilities/RollbarUtility/rollbarUtility.rb')
require_relative File.expand_path(Dir.pwd+"/ManageTourPage/PageObjects/manageTours(Staging).rb")
require_relative File.expand_path(Dir.pwd+"/GemUtilities/EnziTestRailUtility/lib/EnziTestRailUtility.rb")
require "selenium-webdriver"
require "rspec"
require 'enziUIUtility'
require 'date'
#require_relative "helper.rb"
describe ManageTours do
  before(:all){
    
    #SauceLab will read env variable and accordingly set browser
    #@driver = SauceLabs.selenium_driver()
    @objRollbar = RollbarUtility.new()
    #@driver = Selenium::WebDriver.for :chrome
    #@driver = Selenium::WebDriver.for ENV['BROWSER'].to_sym
    @driver = ARGV[0]
    @objManageTours = ManageTours.new(@driver,"Staging")
    @leadsTestData = @objManageTours.instance_variable_get(:@records)[0]['lead']
    @testRailUtility = EnziTestRailUtility::TestRailUtility.new(@objManageTours.instance_variable_get(:@mapCredentials)['TestRail']['username'],@objManageTours.instance_variable_get(:@mapCredentials)['TestRail']['password'])
    @wait = Selenium::WebDriver::Wait.new(:timeout => @objManageTours.instance_variable_get(:@timeSettingMap)['Wait']['Environment']['Lightening']['Min'])
=begin
    arrCaseIds = Array.new
    if !ENV['SECTION_ID'].nil? && ENV['CASE_ID'].nil? then
      @testRailUtility.getCases(ENV['PROJECT_ID'], ENV['SUIT_ID'], ENV['SECTION_ID']).each do |caseId|
        arrCaseIds.push(caseId['id'])
      end
    else
      if !ENV['CASE_ID'].nil? then
        arrCaseIds.push(ENV['CASE_ID'])
      end
    end
    if !ENV['SUIT_ID'].nil? && (!ENV['SECTION_ID'].nil? || !ENV['CASE_ID'].nil?) then
      @runId = @testRailUtility.addRun("Manage Tour by lead",4,19,arrCaseIds)['id']
    else
      @runId = ENV['RUN_ID']
    end
    if ENV['RUN_ID'].nil? then
      @runId = @testRailUtility.addRun("Manage Tour by lead",4,19,arrCaseIds)['id']
    end
=end
    @runId = ENV['RUN_ID']
  }
  before(:each){
    puts "\n"
    puts "---------------------------------------------------------------------------------------------------------------------------"
  }
  after(:each){
    puts "\n"
    puts "---------------------------------------------------------------------------------------------------------------------------"
  }
  after(:all){
    allRecordIds = Salesforce.class_variable_get(:@@createdRecordsIds)
    puts "Deleting created test data of Journey"
    Salesforce.deleteRecords(@objManageTours.instance_variable_get(:@salesforceBulk),"Journey__c",allRecordIds['Journey__c'])
    puts "Test data deleted successfully"
    puts "\n"
    puts "Deleting created test data of Tour"
    Salesforce.deleteRecords(@objManageTours.instance_variable_get(:@salesforceBulk),"Tour_Outcome__c",allRecordIds['Tour_Outcome__c'])
    puts "Test data deleted successfully"
    puts "\n"
    puts "Deleting created test data of Opportunity"
    Salesforce.deleteRecords(@objManageTours.instance_variable_get(:@salesforceBulk),"Opportunity",allRecordIds['Opportunity'])
    puts "Test data deleted successfully"
    puts "\n"
    puts "Deleting created test data of Lead"
    Salesforce.deleteRecords(@objManageTours.instance_variable_get(:@salesforceBulk),"Lead",allRecordIds['Lead'])
    puts "Test data deleted successfully"
    puts "\n"
    puts "Deleting created test data of Account"
    Salesforce.deleteRecords(@objManageTours.instance_variable_get(:@salesforceBulk),"Account",allRecordIds['Account'])
    puts "Test data deleted successfully"
    puts "\n"
    puts "Deleting created test data of Contact"
    Salesforce.deleteRecords(@objManageTours.instance_variable_get(:@salesforceBulk),"Contact",allRecordIds['Contact'])
    puts "Test data deleted successfully"
    #@driver.quit
  }
   puts "---------------------------------------------------------------------------------------------------------------------------"
  it "C149 : To check manage tour page is displayed" , :"149" => true do
    puts "C149 : To check manage tour page is displayed"
    begin
        puts "\n"
        caseInfo = @testRailUtility.getCase('149')
        passedLogs = @objRollbar.addLog("[Step    ]  Checking manage tour page ", caseInfo['id'])
        @leadsTestData[0]['email'] = "test_enzigmaPre#{rand(99999999999999)}@example.com"
        @leadsTestData[0]['company'] = "Test_Enzigma#{rand(99999999999999)}"
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate]  Lead should be created")
        @objManageTours.openPage(Salesforce.createRecords(@objManageTours.instance_variable_get(:@salesforceBulk),'Lead',@leadsTestData)[0]['Id'],:name,"lightning_manage_tours")
        leadName = "#{@objManageTours.instance_variable_get(:@records)[0]['lead'][0]['firstName']}#{@objManageTours.instance_variable_get(:@records)[0]['lead'][0]['lastName']}"
        passedLogs = @objRollbar.addLog("[Expected]  Lead created successfully with leadname #{leadName} \n[Result  ]  Success ")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate]  Checking Journey is created after creating lead")
        @objManageTours.checkRecordCreated("Journey__c","SELECT id FROM Journey__c WHERE Primary_Email__c = '#{@leadsTestData[0]['email']}'")[0].fetch('Id')
        passedLogs = @objRollbar.addLog("[Result  ]  Success")
        
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate]  Checking Title of page when user click on 'Manage/book tour' button")
        expect(@driver.title).to match("Manage Tours")
        passedLogs = @objRollbar.addLog("[Expected]  Manage tour page opened successfully with Page Title= Manage Tours \n[Result  ]  Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ]  Adding result in testrail")
        @testRailUtility.postResult(149,"Pass",1,@runId)
        passedLogs = @objRollbar.addLog("[Result  ]  Success")
    rescue Exception => excp

        passedLogs = @objRollbar.addLog("[Result  ]  Failed")
        @objRollbar.postRollbarData(caseInfo['id'], caseInfo['title'], passedLogs[caseInfo['id']])
       
        Rollbar.error(excp)
        @testRailUtility.postResult(149,"Result for case 149 is #{excp}",5,@runId)
      raise excp
    end
     puts "C149 : Checked successfully"
     puts "---------------------------------------------------------------------------------------------------------------------------"
  end
   
  it "C883 : To check book tour button is disabled" , :"883" => true do
    puts "C883 : To check Book tour button is disabled"
    begin
        puts "\n"
        caseInfo = @testRailUtility.getCase('883')
        passedLogs = @objRollbar.addLog("[Step    ]  Checking 'Book a tour' button ", caseInfo['id'])
        expect(@objManageTours.buttonDisabled?).to be true
        passedLogs = @objRollbar.addLog("[Expected]  'Book a tour' button is disable \n[Result  ]  Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ]  Adding result in testrail")
        @testRailUtility.postResult(883,"Pass",1,@runId)
        passedLogs = @objRollbar.addLog("[Result  ]  Success")
    rescue Exception => excp

        passedLogs = @objRollbar.addLog("[Result  ]  Failed")
       @objRollbar.postRollbarData(caseInfo['id'], caseInfo['title'], passedLogs[caseInfo['id']])
      
        Rollbar.error(excp)

        @testRailUtility.postResult(883,"Result for case 883 is #{excp}",5,@runId)
      raise excp
    end
     puts "C883 : Checked successfully"
     puts "---------------------------------------------------------------------------------------------------------------------------"
  end
     
  it "C7 : To check book tour button get enable" , :"7" => true do
        puts "C7 : To check Book tour button get enable"
        puts "\n"
    begin
        caseInfo = @testRailUtility.getCase('7')
        passedLogs = @objRollbar.addLog("[Step    ]  Checking 'Book a tour' button when all required fields of form are properly filled", caseInfo['id'])
        @objManageTours.bookTour(0,false)
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening']['Min'])
        expect(@objManageTours.buttonDisabled?).to be true
        passedLogs = @objRollbar.addLog("[Expected]  'Book a Tour' button is enabled \n[Result  ]  Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ]  Adding result in testrail")
        @testRailUtility.postResult(7,"Pass",1,@runId)
        passedLogs = @objRollbar.addLog("[Result  ]  Success")
    rescue Exception => excp

       passedLogs = @objRollbar.addLog("[Result  ]  Failed")
       @objRollbar.postRollbarData(caseInfo['id'], caseInfo['title'], passedLogs[caseInfo['id']])
       
       Rollbar.error(excp)

        @testRailUtility.postResult(7,"Result for case 7 is #{excp}",5,@runId)
      raise excp
    end
     puts "C7 : Checked successfully"
     puts "---------------------------------------------------------------------------------------------------------------------------"
  end

  it "C885 : To check user can select tour date without building name", :"885" => true do
        puts "C885  : To check user can select tour date without building name"
        puts "\n"
    begin
        caseInfo = @testRailUtility.getCase('885')
        passedLogs = @objRollbar.addLog("[Step    ]  Checking Building Name and Tour Date fields", caseInfo['id'])
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening']['Min'])
        expect(@objManageTours.childDisabled?(ManageTours.selectBuilding(@driver.find_element(:id,"BookTours0"),nil,@objManageTours.instance_variable_get(:@timeSettingMap),@driver,@objManageTours.instance_variable_get(:@selectorSettingMap)),ManageTours.selectTourDate(@driver.find_element(:id,"BookTours0"),@objManageTours.instance_variable_get(:@timeSettingMap),@driver,@objManageTours.instance_variable_get(:@selectorSettingMap)))).to be false
        passedLogs = @objRollbar.addLog("[Expected]  Tour date field should be disabled as building name field is not filled out \n[Result  ]  Success ")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ]  Adding result in testrail")
        @testRailUtility.postResult(885 ,"Pass",1,@runId)
        passedLogs = @objRollbar.addLog("[Result  ]  Success")
    rescue Exception => excp
        passedLogs = @objRollbar.addLog("[Result  ]  Failed")
       @objRollbar.postRollbarData(caseInfo['id'], caseInfo['title'], passedLogs[caseInfo['id']])
        Rollbar.error(excp)

      @testRailUtility.postResult(885 ,"Result for case 885  is #{excp}",5,@runId)
      raise excp
    end 
     puts "C885 : Checked successfully"
     puts "---------------------------------------------------------------------------------------------------------------------------"
  end
  it "C1016: To check user can select previous date", :"1016" => true do
    puts "C1016: To check user can select previous date"
    begin
        puts "\n"
        caseInfo = @testRailUtility.getCase('1016')
        passedLogs = @objRollbar.addLog("[Step    ]  Checking previous date selection for field tour date",caseInfo['id'])
        passedLogs = @objRollbar.addLog("[Validate]  Checking Tour date field")
        ManageTours.selectTourDate(@driver.find_element(:id,"BookTours0"),@objManageTours.instance_variable_get(:@timeSettingMap),@driver,@objManageTours.instance_variable_get(:@selectorSettingMap))
        EnziUIUtility.clickElement(@driver,:id,Date.today.prev_day.to_s)
        @wait.until {!@driver.find_element(:id ,"spinner").displayed?}
        expect(EnziUIUtility.checkErrorMessage(@driver,'h2','No times slots available for the selected date')).to be true
        @driver.find_elements(:class,"slds-button_icon-inverse")[0].click
        passedLogs = @objRollbar.addLog("[Expected]  Previous tour date should not be selected \n[Result  ]  Success ")
        puts "\n"
     
        passedLogs = @objRollbar.addLog("[Step    ]  Adding result in testrail")
        @testRailUtility.postResult(1016 ,"Pass",1,@runId)
        passedLogs = @objRollbar.addLog("[Result  ]  Success")
    rescue Exception => excp
        passedLogs = @objRollbar.addLog("[Result  ]  Failed")
       @objRollbar.postRollbarData(caseInfo['id'], caseInfo['title'], passedLogs[caseInfo['id']])
       
        Rollbar.error(excp)

      @testRailUtility.postResult(1016 ,"Result for case 1016  is #{excp}",5,@runId)
      raise excp
    end
     puts "C1016: Checked successfully"
     puts "---------------------------------------------------------------------------------------------------------------------------"
  end
  it "C81 : To check user can select start time", :"81" => true  do
    puts "C81 : To check user can select start time"
    puts "\n"
    begin
        caseInfo = @testRailUtility.getCase('81')
        passedLogs = @objRollbar.addLog("[Step]  Start Time field should be selectable",caseInfo['id'])
        ManageTours.selectBuilding(@driver.find_element(:id,"BookTours0"),"#{@objManageTours.instance_variable_get(:@records)[1]['tour'][0]['building']}",@objManageTours.instance_variable_get(:@timeSettingMap),@driver,@objManageTours.instance_variable_get(:@selectorSettingMap))
        ManageTours.selectTourDate(@driver.find_element(:id,"BookTours0"),@objManageTours.instance_variable_get(:@timeSettingMap),@driver,@objManageTours.instance_variable_get(:@selectorSettingMap))
      if Date.today.next_day(1).saturday? then
        EnziUIUtility.clickElement(@driver,:id,Date.today.next_day(2).to_s)
      else
        EnziUIUtility.clickElement(@driver,:id,Date.today.next_day(1).to_s)
        #EnziUIUtility.selectElement(@driver.find_element(:id,"BookTours0"),"Today","a")
      end
      if @driver.find_elements(:class,"startTime").size > 0 then
          expect(@objManageTours.childDisabled?(ManageTours.selectTourDate(@driver.find_element(:id,"BookTours0"),@objManageTours.instance_variable_get(:@timeSettingMap),@driver,@objManageTours.instance_variable_get(:@selectorSettingMap)),ManageTours.setElementValue(@driver.find_element(:id,"BookTours0"),"startTime",nil))).to be false
    	else
        expect(@objManageTours.childDisabled?(ManageTours.selectTourDate(@driver.find_element(:id,"BookTours0"),@objManageTours.instance_variable_get(:@timeSettingMap),@driver,@objManageTours.instance_variable_get(:@selectorSettingMap)),ManageTours.setElementValue(@driver.find_element(:id,"BookTours0"),"startTime2",nil))).to be false
      end
      passedLogs = @objRollbar.addLog("[Expected]  Start Time field should be selected after selecting Building Name and Tour Date fields \n[Result  ]  Success ")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ]  Adding result in testrail")
        @testRailUtility.postResult(81,"Pass",1,@runId)
        passedLogs = @objRollbar.addLog("[Result  ]  Success")
    rescue Exception => excp
        passedLogs = @objRollbar.addLog("[Result  ]  Failed")
       @objRollbar.postRollbarData(caseInfo['id'], caseInfo['title'], passedLogs[caseInfo['id']])
        Rollbar.error(excp)

      @testRailUtility.postResult(81,"Result for case 81 is #{excp}",5,@runId)
      raise excp
    end
     puts "C81 : Checked successfully"
     puts "---------------------------------------------------------------------------------------------------------------------------"
  end
  it "C887 : To check user can get end time automatically after entering start time", :"887" => true do
    puts "C887 : To check user can get end time automatically after entering start time"
    puts "\n"
    begin
        caseInfo = @testRailUtility.getCase('887')
        passedLogs = @objRollbar.addLog("[Step    ]  Checking Start Time and End Time fields", caseInfo['id'])
        if @driver.find_elements(:class,"startTime").size > 0 then
          ManageTours.setElementValue(@driver.find_element(:id,"BookTours0"),"startTime",nil)
          expect(ManageTours.getElement("input","endTime",@driver.find_element(:id,"BookTours0"))).to_not eql nil
        else
          ManageTours.setElementValue(@driver.find_element(:id,"BookTours0"),"startTime2",nil)
          expect(ManageTours.getElement("input","endTime",@driver.find_element(:id,"BookTours0"))).to_not eql nil
        end
        
        passedLogs = @objRollbar.addLog("[Expected]  End Time field should be updated after selecting Start Time \n[Result  ]  Success ")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ]  Adding result in testrail")
        @testRailUtility.postResult(887,"Pass",1,@runId)
        passedLogs = @objRollbar.addLog("[Result  ]  Success")
    rescue Exception => excp
        passedLogs = @objRollbar.addLog("[Result  ]  Failed")
       @objRollbar.postRollbarData(caseInfo['id'], caseInfo['title'], passedLogs[caseInfo['id']])
      
        Rollbar.error(excp)

      @testRailUtility.postResult(887,"Result for case 887 is #{excp}",5,@runId)
      raise excp
    end
     puts "C887 : Checked successfully"
     puts "---------------------------------------------------------------------------------------------------------------------------"
  end
  it "C92 : To check proper error message is displayed when user enter single character in building field", :"92" => true do
    puts "C92 : To check proper error message is displayed when user enter single character in building field"
    puts "\n"
    begin
      caseInfo = @testRailUtility.getCase('92')
        passedLogs = @objRollbar.addLog("[Step    ]  Checking error message after entering single character in Building Name field", caseInfo['id'])
      ManageTours.selectBuilding(@driver.find_element(:id,"BookTours0"),nil,@objManageTours.instance_variable_get(:@timeSettingMap),@driver,@objManageTours.instance_variable_get(:@selectorSettingMap)).clear
      if ManageTours.selectBuilding(@driver.find_element(:id,"BookTours0"),nil,@objManageTours.instance_variable_get(:@timeSettingMap),@driver,@objManageTours.instance_variable_get(:@selectorSettingMap)).attribute('value').length > 2 then
        expect(@driver.find_element(:xpath ,"//span[starts-with(@id, 'lookup-option')]").text).to eql nil
        passedLogs = @objRollbar.addLog("[Expected]  Error message as 'Enter at least 2 characters to search' should be displayed \n[Result  ]  Success ")
        puts "\n"
      else
        expect(@driver.find_element(:xpath ,"//span[starts-with(@id, 'lookup-option')]")).to_not eql nil
      end
      passedLogs = @objRollbar.addLog("[Step    ]  Adding result in testrail")
      @testRailUtility.postResult(92,"Pass",1,@runId)
      passedLogs = @objRollbar.addLog("[Result  ]  Success")
    rescue Exception => excp
        passedLogs = @objRollbar.addLog("[Result  ]  Failed")
         @objRollbar.postRollbarData(caseInfo['id'], caseInfo['title'], passedLogs[caseInfo['id']])
        
        Rollbar.error(excp)

      @testRailUtility.postResult(92,"Result for case 92 is #{excp}",5,@runId)

      raise excp
    end
    #ManageTours.selectBuilding(@driver.find_element(:id,"BookTours0"),nil).clear
     puts "C92 : Checked successfully"
     puts "---------------------------------------------------------------------------------------------------------------------------"
  end
  it "C91 : To check proper lead information is displayed on manage tour page", :"91" => true do
    puts "C91 : To check proper lead information is displayed on manage tour page"
    puts "\n"
    begin
      caseInfo = @testRailUtility.getCase('91')
        passedLogs = @objRollbar.addLog("[Step    ]  Checking lead data on mange tour page", caseInfo['id'])
      if !@driver.find_elements(:id,"Name").empty? then
        expect(@driver.find_element(:id,"Name").attribute('value').eql? "").to be false
        leadName = "#{@objManageTours.instance_variable_get(:@records)[0]['lead'][0]['firstName']}#{@objManageTours.instance_variable_get(:@records)[0]['lead'][0]['lastName']}"
        passedLogs = @objRollbar.addLog("[Validate]  Name field of manage tour page should contain lead name")
        expect(@driver.find_element(:id,"Name").attribute('value').eql? "#{leadName}")
        passedLogs = @objRollbar.addLog("[Expected]  Lead.Name= #{leadName} \n[Result  ]  Success")
        puts "\n"
      end
      
      if !@driver.find_elements(:id,"Company").empty? then

        passedLogs = @objRollbar.addLog("[Validate]  Company field of manage tour page should contain lead company name")
        expect(@driver.find_element(:id,"Company").attribute('value').eql? "").to be false
        expect(@driver.find_element(:id,"Company").attribute('value').eql? "#{@leadsTestData[0]['company']}")
        passedLogs = @objRollbar.addLog("[Expected]  Lead.Company= #{@leadsTestData[0]['company']} \n[Result  ]  Success")
        puts "\n"
      end

      if !@driver.find_elements(:id,"Email").empty? then

        passedLogs = @objRollbar.addLog("[Validate]  Email field of manage tour page should contain lead email id")
        expect(@driver.find_element(:id,"Email").attribute('value').eql? "").to be false
        expect(@driver.find_element(:id,"Email").attribute('value').eql? "#{@leadsTestData[0]['email']}")
        passedLogs = @objRollbar.addLog("[Expected]  Lead.Email= #{@leadsTestData[0]['email']} \n[Result  ]  Success")
        puts "\n"
      end

       passedLogs = @objRollbar.addLog("[Step    ]  Adding result in testrail")
       @testRailUtility.postResult(91,"Pass",1,@runId)
       passedLogs = @objRollbar.addLog("[Result  ]  Success")
    rescue Exception => excp
       passedLogs = @objRollbar.addLog("[Result  ]  Failed")
       @objRollbar.postRollbarData(caseInfo['id'], caseInfo['title'], passedLogs[caseInfo['id']])
       Rollbar.error(excp)
       @testRailUtility.postResult(91,"Result for case 91 is #{excp}",5,@runId)

      raise excp
    end
     puts "C91 : Checked successfully"
     puts "---------------------------------------------------------------------------------------------------------------------------"
  end
  it "C85: To check user can view duplicate account selector page while booking a tour", :"85" => true do
   puts "C85: To check user can view duplicate account selector page while booking a tour and user can book a tour"
    puts "\n"
    begin
        caseInfo = @testRailUtility.getCase('85')
        @objManageTours.bookTour(0,true)
        EnziUIUtility.wait(@driver,:id,"enzi-data-table-container",@objManageTours.instance_variable_get(:@timeSettingMap)['Wait']['Environment']['Lightening']['Max'])
        #puts "#{@driver.find_element(:id,"header43").text} opened successfully"
        
        passedLogs = @objRollbar.addLog("[Step    ]  Duplicate account selector pop-up should be opened", caseInfo['id'])
        EnziUIUtility.wait(@driver,:id,"header43",@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening']['Min'])
        expect(@driver.find_element(:id,"header43").text.eql? "Duplicate Account Selector").to be true
        passedLogs = @objRollbar.addLog("[Expected]  Duplicate account selector pop up is displayed \n[Result  ]  Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ]  Adding result in testrail")
        @testRailUtility.postResult(85,"Result for case 85 is #{"success"}",1,@runId)
        passedLogs = @objRollbar.addLog("[Result  ]  Success")
     
    rescue Exception => excp
     
        passedLogs = @objRollbar.addLog("[Result  ]  Failed")
       @objRollbar.postRollbarData(caseInfo['id'], caseInfo['title'], passedLogs[caseInfo['id']])
       
      Rollbar.error(excp)

      @testRailUtility.postResult(85,"Result for case 85 is #{excp}",5,@runId)
      raise excp
    end
     puts "C85 : Checked successfully"
     puts "---------------------------------------------------------------------------------------------------------------------------"
  end

  context "should test duplicate account selector functionality" do
    it "C86 : To check tour is booked, when user clicks on 'create account and don't merge' button", :"86" => true do
      puts "C86 : To check tour is booked, when user clicks on 'create account and don't merge' button"
      puts "\n"
      begin
        caseInfo = @testRailUtility.getCase('86')
        
        puts "\n"
        EnziUIUtility.wait(@driver,:id,"enzi-data-table-container",@objManageTours.instance_variable_get(:@timeSettingMap)['Wait']['Environment']['Lightening']['Max'])

        passedLogs = @objRollbar.addLog("[Step    ]  Click on 'Create Account and Don't Merge' button",caseInfo['id'])
        @objManageTours.duplicateAccountSelector("Create Account and Don't Merge",nil)

        leadName = "#{@objManageTours.instance_variable_get(:@records)[0]['lead'][0]['firstName']}#{@objManageTours.instance_variable_get(:@records)[0]['lead'][0]['lastName']}"
        passedLogs = @objRollbar.addLog("[Validate]  #{leadName} named lead should be converted")
        expect(@objManageTours.checkRecordCreated("Lead","SELECT id,isConverted FROM Lead WHERE Email = '#{@leadsTestData[0]['email']}'")[0].fetch("IsConverted").eql? 'true').to be true
        passedLogs = @objRollbar.addLog("[Expected]  Successfully lead is converted \n[Result  ]  Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate]  Contact Should be created with name #{leadName}")
        expect(@objManageTours.checkRecordCreated("Contact","SELECT id,total_Scheduled_Tours__c FROM Contact WHERE Email = '#{@leadsTestData[0]['email']}'")[0].fetch("Id")).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected]  Successfully contact is created \n[Result  ]  Success")
        puts "\n"
        
        passedLogs = @objRollbar.addLog("[Validate]  Account Should be created with name #{@leadsTestData[0]['company']}")
        expect(@objManageTours.checkRecordCreated("Account","SELECT id,allow_merge__c FROM Account WHERE name = '#{@leadsTestData[0]['company']}'")[0].fetch("Id")).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected]  Successfully account is created \n[Result  ]  Success")
        puts "\n"
      
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening']['Max'])
        createdOpportunity = @objManageTours.checkRecordCreated("Opportunity","SELECT id,name FROM Opportunity WHERE Account.name = '#{@leadsTestData[0]['company']}'")[0]
        passedLogs = @objRollbar.addLog("[Validate]  Opportunity should be created with name #{createdOpportunity.fetch("Name")}")
        expect(createdOpportunity.fetch("Id")).to_not eql nil
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening']['Min'])
        passedLogs = @objRollbar.addLog("[Expected]  Successfully opportunity is created \n[Result  ]  Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate]  To check allow merge field on Account")
        expect(ManageTours.class_variable_get(:@@recordInsertedIds)['Account'].fetch('Allow_Merge__c').eql? 'false').to be true
        passedLogs = @objRollbar.addLog("[Expected]  Allow merge = #{ManageTours.class_variable_get(:@@recordInsertedIds)['Account'].fetch('Allow_Merge__c')}\t \n[Result  ]  Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate]  Checking total number of scheduled tours on contact")
        expect(ManageTours.class_variable_get(:@@recordInsertedIds)['Contact'].fetch('Total_Scheduled_Tours__c').to_i > 0).to be true
        passedLogs = @objRollbar.addLog("[Expected]  Total number of scheduled tours = #{ManageTours.class_variable_get(:@@recordInsertedIds)['Contact'].fetch('Total_Scheduled_Tours__c')}\t \n[Result  ]  Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate]  Tour should be created")
        expect(@objManageTours.checkRecordCreated("Tour_Outcome__c","SELECT id,Status__c FROM Tour_Outcome__c WHERE Primary_Member__r.email = '#{@leadsTestData[0]['email']}'")[0].fetch("Id")).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected]  Successfully tour is created \n[Result  ]  Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate]  Success message for booked tour should be displayed \n[Expected]  Success Message as 'Tour booked successfully and will be synced shortly' and 'Tours synced successfully' should be displayed \n[Result  ]  Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate]  Status of created tour should updated as 'Scheduled'")
        expect(ManageTours.class_variable_get(:@@recordInsertedIds)['Tour_Outcome__c'].fetch('Status__c').eql? "Scheduled").to be true
        passedLogs = @objRollbar.addLog("[Expected]  Status= #{ManageTours.class_variable_get(:@@recordInsertedIds)['Tour_Outcome__c'].fetch('Status__c')} \n[Result  ]  Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate]  Activity should be created for tour")
        expect(@objManageTours.checkRecordCreated('Task',"SELECT id FROM Task WHERE whatId = '#{ManageTours.class_variable_get(:@@recordInsertedIds)['Tour_Outcome__c'].fetch('Id')}'")[0].fetch('Id')).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected]  'Book a tour' activity is created \n[Result  ]  Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ]  Adding result in testrail")
        @testRailUtility.postResult(86,"Pass",1,@runId)
        passedLogs = @objRollbar.addLog("[Result  ]  Success")

      rescue Exception => excp
         passedLogs = @objRollbar.addLog("[Result  ]  Failed")
         @objRollbar.postRollbarData(caseInfo['id'], caseInfo['title'], passedLogs[caseInfo['id']])
        
         Rollbar.error(excp)

        @testRailUtility.postResult(86,"Result for case 86 is #{excp}",5,@runId)
        raise excp
      end
       puts "C86 : Checked successfully"
       puts "---------------------------------------------------------------------------------------------------------------------------"
    end
    it "C89 : To check user can view booked tours information", :"89" => true do
      puts "C89 : To check user can view booked tours information"
      puts "\n"
      begin
        caseInfo = @testRailUtility.getCase('89')
        passedLogs = @objRollbar.addLog("[Step    ]  Checking booked tour information", caseInfo['id'])

        expect(@objManageTours.numberOfTourBooked == 3).to be true
        passedLogs = @objRollbar.addLog("[Expected]  Tour records are displayed on same manage tour page \n[Result  ]  Success")
        puts "\n"
        passedLogs = @objRollbar.addLog("[Step    ]  Adding result in testrail")
        @testRailUtility.postResult(89,"Pass",1,@runId)
        passedLogs = @objRollbar.addLog("[Result  ]  Success")
     
      rescue Exception => excp
        passedLogs = @objRollbar.addLog("[Result  ]  Failed")
         @objRollbar.postRollbarData(caseInfo['id'], caseInfo['title'], passedLogs[caseInfo['id']])
          
         Rollbar.error(excp)

        @testRailUtility.postResult(89,"Result for case 89 is #{excp}",5,@runId)
        raise excp
      end
       puts "C89 : Checked successfully"
       puts "---------------------------------------------------------------------------------------------------------------------------"
    end
    context "check multiple tour booking" do
      it "C96 : To check user can book multiple tour", :"96" => true do
        puts "C96 : To check user can book multiple tour"
        puts "\n"
        begin
        caseInfo = @testRailUtility.getCase('96')
        passedLogs = @objRollbar.addLog("[Step    ]  To book first tour enter values in fields",caseInfo['id'])
        @objManageTours.bookNewTour
        @objManageTours.bookTour(0,true)
        passedLogs = @objRollbar.addLog("[Expected]  Fields should accept all valid values\n[Result  ]  Success ")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ]  To book second tour enter values in fields")
        @objManageTours.bookTour(1,true)
        passedLogs = @objRollbar.addLog("[Expected]  Fields should accept all valid values\n[Result  ]  Success ")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ]  Multiple tours should be booked")
        @objManageTours.duplicateAccountSelector("Create Account and Don't Merge",nil)
        bookedTours = @objManageTours.checkRecordCreated("Tour_Outcome__c","SELECT id,Status__c FROM Tour_Outcome__c WHERE Primary_Member__r.email = '#{@leadsTestData[0]['email']}'")
        expect(bookedTours.size > 1).to be true
        passedLogs = @objRollbar.addLog("[Expected]  Multiple tours are booked \n[Result  ]  Success")
        puts "\n"
        
        passedLogs = @objRollbar.addLog("[Validate]  Open activities for tours should be created")
        expect(@objManageTours.checkRecordCreated('Task',"SELECT id FROM Task WHERE whatId = '#{bookedTours[0].fetch('Id')}'")[0].fetch('Id')).to_not eql nil
        expect(@objManageTours.checkRecordCreated('Task',"SELECT id FROM Task WHERE whatId = '#{bookedTours[1].fetch('Id')}'")[0].fetch('Id')).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected]  Open activities are created for multiple tours \n[Result  ]  Success")
        puts "\n"

        @wait.until {!@driver.find_element(:id ,"spinner").displayed?}
        passedLogs = @objRollbar.addLog("[Validate]  Records of booked tour should be displayed")
        expect(@objManageTours.numberOfTourBooked > 3).to be true
        passedLogs = @objRollbar.addLog("[Expected]  Booked tours records are available on manage tour page \n[Result  ]  Success")
        puts "\n"
        
        passedLogs = @objRollbar.addLog("[Step    ]  Adding result in testrail")
        @testRailUtility.postResult(96,"Pass",1,@runId)
        passedLogs = @objRollbar.addLog("[Result  ]  Success")
        rescue Exception => excp
          passedLogs = @objRollbar.addLog("[Result  ]  Failed")
           @objRollbar.postRollbarData(caseInfo['id'], caseInfo['title'], passedLogs[caseInfo['id']]) 
          Rollbar.error(excp)
          @testRailUtility.postResult(96,"Result for case 96 is #{excp}",5,@runId)
          raise excp
        end
        puts "C96 : Checked successfully"
        puts "---------------------------------------------------------------------------------------------------------------------------"
        
      end   
    end
    it "C94 : To check tour is booked, when user clicks on 'create account and merge' button", :"94" => true do
      puts "C94 : To check tour is booked, when user clicks on 'create account and merge' button"
      puts "\n"
      begin
        caseInfo = @testRailUtility.getCase('94')
        passedLogs = @objRollbar.addLog("[Step    ]  Click on 'Create Account and merge' button",caseInfo['id'])
        @leadsTestData[0]['email'] = "test_enzigmaPre#{rand(99999999999999)}@example.com"
        @leadsTestData[0]['company'] = "Test_Enzigma#{rand(99999999999999)}"
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate]  Lead should be created")
        if @driver.title.eql? "Manage Tours" then
          @objManageTours.openPageForLead(Salesforce.createRecords(@objManageTours.instance_variable_get(:@salesforceBulk),'Lead',@leadsTestData)[0]['Id'])
        else
          @objManageTours.openPage(Salesforce.createRecords(@objManageTours.instance_variable_get(:@salesforceBulk),'Lead',@leadsTestData)[0]['Id'],:name,"lightning_manage_tours")
        end
        passedLogs = @objRollbar.addLog("[Expected] Lead created sucessfully \n[Result  ]  Success")
        puts "\n"

        @objManageTours.checkRecordCreated("Journey__c","SELECT id FROM Journey__c WHERE Primary_Email__c = '#{@leadsTestData[0]['email']}'")[0].fetch('Id')
        @objManageTours.bookTour(0,true)
        @objManageTours.duplicateAccountSelector("Create Account and Merge",nil)
        passedLogs = @objRollbar.addLog("[Validate]  Lead with #{@leadsTestData[0]['email']} email id should be converted",caseInfo['id'])
        expect(@objManageTours.checkRecordCreated("Lead","SELECT id,isConverted FROM Lead WHERE Email = '#{@leadsTestData[0]['email']}'")[0].fetch("IsConverted").eql? 'true').to be true
        passedLogs = @objRollbar.addLog("[Expected]  Lead converted Sucessfully \n[Result  ]  Success")
        puts "\n"

        leadName = "#{@objManageTours.instance_variable_get(:@records)[0]['lead'][0]['firstName']}#{@objManageTours.instance_variable_get(:@records)[0]['lead'][0]['lastName']}"
        passedLogs = @objRollbar.addLog("[Validate]  Account should be created with name #{@leadsTestData[0]['company']}")
        expect(@objManageTours.checkRecordCreated("Account","SELECT id,allow_merge__c FROM Account WHERE name = '#{@leadsTestData[0]['company']}'")[0].fetch("Id")).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected]  Account created successfully \n[Result  ]  Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate]  Opportunity should be created")
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening']['Max'])
        expect(@objManageTours.checkRecordCreated("Opportunity","SELECT id FROM Opportunity WHERE Account.name = '#{@leadsTestData[0]['company']}'")[0].fetch("Id")).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected]  Opportunity created successfully \n[Result  ]  Success")
        puts "\n"
        
        passedLogs = @objRollbar.addLog("[Validate]  To check allow merge field on Account")
        expect(ManageTours.class_variable_get(:@@recordInsertedIds)['Account'].fetch('Allow_Merge__c').eql? 'true').to be true
        passedLogs = @objRollbar.addLog("[Expected]  Allow merge  = #{ManageTours.class_variable_get(:@@recordInsertedIds)['Account'].fetch('Allow_Merge__c')}\t \n[Result  ]  Success")
        puts "\n"
      
        passedLogs = @objRollbar.addLog("[Validate]  Tour should be created")
        expect(@objManageTours.checkRecordCreated("Tour_Outcome__c","SELECT id,Status__c FROM Tour_Outcome__c WHERE Primary_Member__r.email = '#{@leadsTestData[0]['email']}'")[0].fetch("Id")).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected]  Tour created successfully \n[Result  ]  Success")
        puts"\n"

        passedLogs = @objRollbar.addLog("[Validate]  Contact should be created with name #{leadName}")
        expect(@objManageTours.checkRecordCreated("Contact","SELECT id,total_Scheduled_Tours__c FROM Contact WHERE Email = '#{@leadsTestData[0]['email']}'")[0].fetch("Id")).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected]  Contact created successfully \n[[Result  ]  Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate]  Checking total number of scheduled tours on contact")
        expect(ManageTours.class_variable_get(:@@recordInsertedIds)['Contact'].fetch('Total_Scheduled_Tours__c').to_i > 0).to be true
        passedLogs = @objRollbar.addLog("[Expected]  Total number of scheduled tours = #{ManageTours.class_variable_get(:@@recordInsertedIds)['Contact'].fetch('Total_Scheduled_Tours__c')}\t \n[Result  ]  Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate]  Success message for booked tour should be displayed \n[Expected]  Success Message as 'Tour booked successfully and will be synced shortly' and 'Tours synced successfully' should be displayed \n[Result  ]  Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate]  Status of created tour should updated as 'Scheduled' ")
        expect(ManageTours.class_variable_get(:@@recordInsertedIds)['Tour_Outcome__c'].fetch('Status__c').eql? "Scheduled").to be true
        passedLogs = @objRollbar.addLog("[Expected]  Status =Scheduled \n[Result  ]  Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate]  Checking open activities")
        expect(@objManageTours.checkRecordCreated('Task',"SELECT id FROM Task WHERE whatId = '#{ManageTours.class_variable_get(:@@recordInsertedIds)['Tour_Outcome__c'].fetch('Id')}'")[0].fetch('Id')).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected]  'Book a tour' named open activity created successfully \n[Result  ]  Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate]   Records of booked tour should be displayed")
        expect(@objManageTours.numberOfTourBooked == 3).to be true
        passedLogs = @objRollbar.addLog("[Expected]  Booked tours records are available on manage tour page \n[Result  ]  Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ]  Adding result in testrail")
        @testRailUtility.postResult(94,"Pass",1,@runId)
        passedLogs = @objRollbar.addLog("[Result  ]  Success")
       
      rescue Exception => excp
         passedLogs = @objRollbar.addLog("[Result  ]  Failed")
         @objRollbar.postRollbarData(caseInfo['id'], caseInfo['title'], passedLogs[caseInfo['id']])
         
         Rollbar.error(excp)

        @testRailUtility.postResult(94,"Result for case 94 is #{excp}",5,@runId)

        raise excp
      end
        puts "C94 : Checked successfully"
        puts "---------------------------------------------------------------------------------------------------------------------------"
       
    end
    it "C129 : to check user can cancel a tour"  , :"129" => true do
      puts "C129 : to check user can cancel a tour"
      puts "\n"
      begin
        caseInfo = @testRailUtility.getCase('129')
        passedLogs = @objRollbar.addLog("[Step    ]  User should fill cancellation reason", caseInfo['id'])
        passedLogs = @objRollbar.addLog("[Validate]  Cancel tour pop-up should accept cancellation reason \n[Result  ]  Success" )
       
        EnziUIUtility.selectElement(@driver,"Cancel","button")
        EnziUIUtility.wait(@driver,:id,"header43",@objManageTours.instance_variable_get(:@timeSettingMap)['Wait']['Environment']['Lightening']['Min'])
        EnziUIUtility.selectChild(@driver,:id,"Cancellation_Reason__c","No reason (didn't provide)","option")
        passedLogs = @objRollbar.addLog("[Expected]  Cancellation Reason= No reason \n[Result  ]  Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate]  Save button should be enabled after filling out cancellation reason")
        EnziUIUtility.selectElement(@driver,"Save","button")
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening']['Max'])
        passedLogs = @objRollbar.addLog("[Expected]  Save button get enabled \n[Result  ]  Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate]  Status of tour should be changed after cancellation of tour")
        expect(@objManageTours.tourStatusChecked?("Cancelled" , @leadsTestData[0]['email'])).to be true
        passedLogs = @objRollbar.addLog("[Expected]  Tour status=Cancelled \n[Result  ]  Success")
        puts "\n"
      
        passedLogs = @objRollbar.addLog("[Step    ]  Adding result in testrail")
        @testRailUtility.postResult(129,"Pass",1,@runId)
        passedLogs = @objRollbar.addLog("[Result  ]  Success")
       
      rescue Exception => excp
        passedLogs = @objRollbar.addLog("[Result  ]  Failed")
         @objRollbar.postRollbarData(caseInfo['id'], caseInfo['title'], passedLogs[caseInfo['id']])
        
         Rollbar.error(excp)

        @testRailUtility.postResult(129,"Result for case 129 is #{excp}",5,@runId)
        raise excp
      end
      puts "C129 : Checked successfully"
      puts "---------------------------------------------------------------------------------------------------------------------------"
        
    end
    it "C102 : To check tour is booked, when user clicks on 'Use Selector Account' button" , :"102" => true do
      puts "C102 : To check tour is booked, when user clicks on 'Use Selector Account' button"
      puts "\n"
      begin
        caseInfo = @testRailUtility.getCase('102')
        passedLogs = @objRollbar.addLog("[Step    ]  Click on 'Use Selector Account' button",caseInfo['id'])
        
        passedLogs = @objRollbar.addLog("[Validate]  Lead should be created")
        @leadsTestData[0]['email'] = "test_enzigmaPre#{rand(99999999999999)}@example.com"
        if @driver.title.eql? "Manage Tours"
          @objManageTours.openPageForLead(Salesforce.createRecords(@objManageTours.instance_variable_get(:@salesforceBulk),'Lead',@leadsTestData)[0]['Id'])
        else
          @objManageTours.openPage(Salesforce.createRecords(@objManageTours.instance_variable_get(:@salesforceBulk),'Lead',@leadsTestData)[0]['Id'],:name,"lightning_manage_tours")
        end
        passedLogs = @objRollbar.addLog("[Expected] Lead created sucessfully \n[Result  ]  Success")
        puts "\n"

        @objManageTours.checkRecordCreated("Journey__c","SELECT id FROM Journey__c WHERE Primary_Email__c = '#{@leadsTestData[0]['email']}'")[0].fetch('Id')
        @objManageTours.bookTour(0,true)
        @objManageTours.duplicateAccountSelector("Use Selected Account","Yes")
        passedLogs = @objRollbar.addLog("[Validate]  Lead with #{@leadsTestData[0]['email']} email id should be converted")
        expect(@objManageTours.checkRecordCreated("Lead","SELECT id,isConverted FROM Lead WHERE Email = '#{@leadsTestData[0]['email']}'")[0].fetch("IsConverted").eql? 'true').to be true
        passedLogs = @objRollbar.addLog("[Expected]  Lead converted Sucessfully \n[Result  ]  Success")
        puts "\n"
        
        passedLogs = @objRollbar.addLog("[Validate]  Contact should be created")
        expect(@objManageTours.checkRecordCreated("Contact","SELECT id,Account.name FROM Contact WHERE Email = '#{@leadsTestData[0]['email']}'")[0].fetch("Id")).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected]  Contact created successfully \n[Result  ]  Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate]  Tour should be created")
        expect(@objManageTours.checkRecordCreated("Tour_Outcome__c","SELECT id,Status__c FROM Tour_Outcome__c WHERE Primary_Member__r.email = '#{@leadsTestData[0]['email']}'")[0].fetch("Id")).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected]  Tour created successfully \n[Result  ]  Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate]  Success message for booked tour should be displayed \n[Expected]  Success Message as 'Tour booked successfully and will be synced shortly' and 'Tours synced successfully' should be displayed \n[Result  ]  Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate]  To check status of booked tour")
        expect(ManageTours.class_variable_get(:@@recordInsertedIds)['Tour_Outcome__c'].fetch('Status__c').eql? "Scheduled").to be true
        passedLogs = @objRollbar.addLog("[Expected]  Status = #{ManageTours.class_variable_get(:@@recordInsertedIds)["Tour_Outcome__c"].fetch("Status__c")} \n[Result  ]  Success")
        puts "\n"

        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening']['Min'])
        passedLogs = @objRollbar.addLog("[Validate]  Checking open activities")
        expect(@objManageTours.checkRecordCreated('Task',"SELECT id FROM Task WHERE whatId = '#{ManageTours.class_variable_get(:@@recordInsertedIds)['Tour_Outcome__c'].fetch('Id')}'")[0].fetch('Id')).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected]  'Book a tour' named open activity created successfully \n[Result  ]  Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate]  Records of booked tour should be displayed")
        expect(@objManageTours.numberOfTourBooked == 3).to be true
        passedLogs = @objRollbar.addLog("[Expected]  Booked tours records are available on manage tour page \n[Result  ]  Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ]  Adding result in testrail")
        @testRailUtility.postResult(102,"Pass",1,@runId)
        passedLogs = @objRollbar.addLog("[Result  ]  Success")
       
      rescue Exception => excp
         passedLogs = @objRollbar.addLog("[Result  ]  Failed")
         @objRollbar.postRollbarData(caseInfo['id'], caseInfo['title'], passedLogs[caseInfo['id']])
         Rollbar.error(excp)
        @testRailUtility.postResult(102,"Result for case 102 is #{excp}",5,@runId)
        raise excp
      end
       puts "C102 : Checked successfully"
       puts "---------------------------------------------------------------------------------------------------------------------------"
        
    end
    
  end

  context "should check reschedule functionality" do
    it "C115 : To check user can reschedule a tour" , :"115" => true do
      puts "C115 : To check user can reschedule a tour"
      puts "\n"
      begin
        caseInfo = @testRailUtility.getCase('115')
        passedLogs = @objRollbar.addLog("[Step    ]  Check status of tour after tour rescheduling \n[Validate]  Status of tour should be updated as Rescheduled", caseInfo['id'])
        @objManageTours.rescheduleTour
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening']['Max'])
        expect(@objManageTours.tourStatusChecked?("Rescheduled" , @leadsTestData[0]['email'])).to be true
        passedLogs = @objRollbar.addLog("[Expected]  Status = Rescheduled \n[Result  ]  Success")  
        puts "\n"
        
        passedLogs = @objRollbar.addLog("[Step    ]  Adding result in testrail")
        @testRailUtility.postResult(115,"Pass",1,@runId)
        passedLogs = @objRollbar.addLog("[Result  ]  Success")
        
      rescue Exception => excp
        passedLogs = @objRollbar.addLog("[Result  ]  Failed")
         @objRollbar.postRollbarData(caseInfo['id'], caseInfo['title'], passedLogs[caseInfo['id']])
         
         Rollbar.error(excp)
        @testRailUtility.postResult(115,"Result for case 115 is #{excp}",5,@runId)
        raise excp
      end
       puts "C115 : Checked successfully"
       puts "---------------------------------------------------------------------------------------------------------------------------"
    end     
  end
end

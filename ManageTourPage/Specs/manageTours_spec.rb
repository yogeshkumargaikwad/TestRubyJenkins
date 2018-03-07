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
    @driver = Selenium::WebDriver.for ENV['BROWSER'].to_sym
    @objManageTours = ManageTours.new(@driver,"Staging")
    @leadsTestData = @objManageTours.instance_variable_get(:@records)[0]['lead']
    @testRailUtility = EnziTestRailUtility::TestRailUtility.new(@objManageTours.instance_variable_get(:@mapCredentials)['TestRail']['username'],@objManageTours.instance_variable_get(:@mapCredentials)['TestRail']['password'])
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
    #puts "Records to delete :: #{allRecordIds}"
    #Salesforce.deleteRecords(@objManageTours.instance_variable_get(:@salesforceBulk),"Journey__c",[@objManageTours.instance_variable_get(:@recordInsertedIdsToDelete)['Journey__c']['Id']])
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
    Salesforce.deleteRecords(@objManageTours.instance_variable_get(:@salesforceBulk),"Lead",allRecordIds['Lead'].uniq)
    puts "Test data deleted successfully"
    puts "\n"
    puts "Deleting created test data of Account"
    Salesforce.deleteRecords(@objManageTours.instance_variable_get(:@salesforceBulk),"Account",allRecordIds['Account'])
    puts "Test data deleted successfully"
    puts "\n"
    puts "Deleting created test data of Contact"
    Salesforce.deleteRecords(@objManageTours.instance_variable_get(:@salesforceBulk),"Contact",allRecordIds['Contact'])
    puts "Test data deleted successfully"
    @driver.quit
  }
   puts "---------------------------------------------------------------------------------------------------------------------------"
  it "C149 : To check manage tour page is displayed" , :"149" => true do
    puts "C149 : To check manage tour page is displayed"
    begin
        puts "\n"
        caseInfo = @testRailUtility.getCase('149')
        passedLogs = @objRollbar.addLog("[Step    ]  Checking manage tour page ", caseInfo['id'])
        @leadsTestData[0]['email'] = "test_enzigmaPre#{rand(9999)}@example.com"
        @leadsTestData[0]['company'] = "Test_Enzigma#{rand(1111)}"
        
       # puts "[Step]     Checking manage tour page"
        puts "\n"
        @objManageTours.openPage(Salesforce.createRecords(@objManageTours.instance_variable_get(:@salesforceBulk),'Lead',@leadsTestData)[0]['Id'],:name,"lightning_manage_tours")

      #@objManageTours.openPage(@objManageTours.checkRecordCreated("Journey__c","SELECT id FROM Journey__c WHERE Primary_Email__c = '#{@objManageTours.instance_variable_get(:@records)[0]['lead'][0]['email']}'")[0].fetch('Id'),:id,"taction:0")
        @objManageTours.checkRecordCreated("Journey__c","SELECT id FROM Journey__c WHERE Primary_Email__c = '#{@leadsTestData[0]['email']}'")[0].fetch('Id')
        expect(@driver.title).to eql "Manage Tours"
        passedLogs = @objRollbar.addLog("[Expected]  Manage tour page opened successfully \n[Result  ]  Success")
        #puts "[Expected]  Manage tour page opened successfully"
        #puts "[Result]    Success"
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
   
  it "C883 : To check book tour button is disabled" do
    puts "C883 : To check Book tour button is disabled"
    begin
        puts "\n"
        caseInfo = @testRailUtility.getCase('883')
        passedLogs = @objRollbar.addLog("[Step    ]  Checking 'Book a tour' button ", caseInfo['id'])
        #puts "[Step]     Checking 'Book a tour' button"
        expect(@objManageTours.buttonDisabled?).to be true
        passedLogs = @objRollbar.addLog("[Expected]  'Book a tour' button is disable \n[Result  ]  Success")
        #puts "[Expected] 'Book a tour' button is disable"
        #puts "[Result]    Success"
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
     
  it "C7 : To check book tour button get enable" do
        puts "C7 : To check Book tour button get enable"
        puts "\n"
    begin
        caseInfo = @testRailUtility.getCase('7')
        passedLogs = @objRollbar.addLog("[Step    ]  Checking 'Book a tour' button when all required fields of form are properly filled", caseInfo['id'])
        #puts "[Step]     Checking 'Book a tour' button when all required fields of form are properly filled"
        @objManageTours.bookTour(0,false)
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        expect(@objManageTours.buttonDisabled?).to be true
        passedLogs = @objRollbar.addLog("[Expected]  'Book a Tour' button is enabled \n[Result  ]  Success")
        #puts "[Expected] 'Book a Tour' button is enabled"
        #puts "[Result]   Success"
        puts "\n"
        passedLogs = @objRollbar.addLog("[Step    ]  Adding result in testrail")
        @testRailUtility.postResult(7,"Pass",1,@runId)
        passedLogs = @objRollbar.addLog("[Result  ]  Success")
    rescue Exception => excp

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

  it "C885 : To check user can select tour date without building name", :regression => true do
        puts "C885  : To check user can select tour date without building name"
        puts "\n"
    begin
        caseInfo = @testRailUtility.getCase('885')
        passedLogs = @objRollbar.addLog("[Step    ]  Checking Building Name and Tour Date fields", caseInfo['id'])
        #puts "[Step]     Checking Building Name and Tour Date fields"
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        expect(@objManageTours.childDisabled?(ManageTours.selectBuilding(@driver.find_element(:id,"BookTours0"),nil,@objManageTours.instance_variable_get(:@timeSettingMap)),ManageTours.selectTourDate(@driver.find_element(:id,"BookTours0"),@objManageTours.instance_variable_get(:@timeSettingMap)))).to be false
        passedLogs = @objRollbar.addLog("[Expected]  Tour date field should be disabled as building name field is not filled out \n[Result  ]  Success ")
        #puts "[Expected] Tour date field should be disabled as building name field is not filled out"
        #puts "[Result]   Success"
      #puts "C885 : successfully checked"
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
  it "C1016: To check user can select previous date" do
    puts "C1016: To check user can select previous date"
    begin
        puts "\n"
        caseInfo = @testRailUtility.getCase('1016')
         passedLogs = @objRollbar.addLog("[Step    ]  Checking Tour date field for previous date", caseInfo['id'])
        #puts "[Step]     Checking Tour date field for previous date"
        ManageTours.selectTourDate(@driver.find_element(:id,"BookTours0"),@objManageTours.instance_variable_get(:@timeSettingMap))
        EnziUIUtility.clickElement(@driver,:id,Date.today.prev_day.to_s)
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        expect(EnziUIUtility.checkErrorMessage(@driver,'h2','No times slots available for the selected date')).to be true
        @driver.find_elements(:class,"slds-button_icon-inverse")[0].click
        passedLogs = @objRollbar.addLog("[Expected]  Previous tour date should not be selected \n[Result  ]  Success ")
        #puts "[Expected] Previous tour date should not be selected"
        #puts "[Result]   Success"
        puts "\n"
      #puts "successfully checked C1016"
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
  it "C81 : To check user can select start time"  do
    puts "C81 : To check user can select start time"
    puts "\n"
    begin
        caseInfo = @testRailUtility.getCase('81')
         passedLogs = @objRollbar.addLog("[Step    ]  Start Time field should be selectable", caseInfo['id'])
        #puts "[Step]     Start Time field should be selected"
        ManageTours.selectBuilding(@driver.find_element(:id,"BookTours0"),"LA-Santa Monica",@objManageTours.instance_variable_get(:@timeSettingMap))
        ManageTours.selectTourDate(@driver.find_element(:id,"BookTours0"),@objManageTours.instance_variable_get(:@timeSettingMap))
      if Date.today.saturday? || Date.today.sunday? then
        EnziUIUtility.clickElement(@driver,:id,Date.today.next_day(2).to_s)
      else
        EnziUIUtility.selectElement(@driver.find_element(:id,"BookTours0"),"Today","a")
      end
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        expect(@objManageTours.childDisabled?(ManageTours.selectTourDate(@driver.find_element(:id,"BookTours0"),@objManageTours.instance_variable_get(:@timeSettingMap)),ManageTours.setElementValue(@driver.find_element(:id,"BookTours0"),"startTime",nil))).to be false
     # puts "C81 : successfully checked"
         passedLogs = @objRollbar.addLog("[Expected]  Start Time field should be selected after selecting Building Name and Tour Date fields \n[Result  ]  Success ")
        #puts "[Expected] Start Time field should be selected after selecting Building Name and Tour Date fields"
        #puts "[Result]   Success"
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
  it "C887 : To check user can get end time automatically after entering start time" do
    puts "C887 : To check user can get end time automatically after entering start time"
    puts "\n"
    begin
        caseInfo = @testRailUtility.getCase('887')
        passedLogs = @objRollbar.addLog("[Step    ]  Checking Start Time and End Time fields", caseInfo['id'])
        #puts "[Step]     Checking Start Time and End Time fields"
        ManageTours.setElementValue(@driver.find_element(:id,"BookTours0"),"startTime",nil)
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        expect(ManageTours.getElement("input","endTime",@driver.find_element(:id,"BookTours0"))).to_not eql nil
      #puts "C887 : successfully checked"
        passedLogs = @objRollbar.addLog("[Expected]  End Time field should be selected after selecting Start Time \n[Result  ]  Success ")
        #puts "[Expected] End Time field should be selected after selecting Start Time"
        #puts "[Result]   Success"
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
  it "C92 : To check proper error message is displayed when user enter single character in building field" do
    puts "C92 : To check proper error message is displayed when user enter single character in building field"
    puts "\n"
    begin
      caseInfo = @testRailUtility.getCase('92')
      passedLogs = @objRollbar.addLog("[Step    ]  Checking error message after entering single character in Building Name field", caseInfo['id'])
        #puts "[Step]     Checking error message after entering single character in Building Name field"
      ManageTours.selectBuilding(@driver.find_element(:id,"BookTours0"),nil,@objManageTours.instance_variable_get(:@timeSettingMap)).clear
      #ManageTours.selectBuilding(@driver.find_element(:id,"BookTours0"),nil).send_keys "a"
      if ManageTours.selectBuilding(@driver.find_element(:id,"BookTours0"),nil,@objManageTours.instance_variable_get(:@timeSettingMap)).attribute('value').length > 2 then
        expect(@driver.find_element(:xpath ,"//span[starts-with(@id, 'lookup-option')]").text).to eql nil
        #puts "C92 : successfully checked"

        passedLogs = @objRollbar.addLog("[Expected]  Error message as 'Enter at least 2 characters to search' should be displayed \n[Result  ]  Success ")
        #puts "[Expected] Error message as 'Enter at least 2 characters to search' should be displayed "
        #puts "[Result]   Success"
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
  it "C91 : To check proper lead information is displayed on manage tour page" do
    puts "C91 : To check proper lead information is displayed on manage tour page"
    puts "\n"
    begin
      caseInfo = @testRailUtility.getCase('91')
      passedLogs = @objRollbar.addLog("[Step    ]  Checking lead data on mange tour page", caseInfo['id'])
        #puts "[Step]     Checking lead data on mange tour page"
      if !@driver.find_elements(:id,"Name").empty? then
        expect(@driver.find_element(:id,"Name").attribute('value').eql? "").to be false
        leadName = "#{@objManageTours.instance_variable_get(:@records)[0]['lead'][0]['firstName']}#{@objManageTours.instance_variable_get(:@records)[0]['lead'][0]['lastName']}"
        expect(@driver.find_element(:id,"Name").attribute('value').eql? "#{leadName}")
        passedLogs = @objRollbar.addLog("[Validate]  Does Name field of manage tour page contain lead name?");
        passedLogs = @objRollbar.addLog("[Expected]  Lead.Name= #{leadName} \n[Result  ]  Success")
        #puts "[Validate] Does Name field of manage tour page contain lead name?"
        #puts "[Expected] Lead.Name= #{leadName}"
        #puts "[Result]   Success"
        puts "\n"
      end
      
      if !@driver.find_elements(:id,"Company").empty? then
        expect(@driver.find_element(:id,"Company").attribute('value').eql? "").to be false
        expect(@driver.find_element(:id,"Company").attribute('value').eql? "#{@leadsTestData[0]['company']}")

        passedLogs = @objRollbar.addLog("[Validate]  Does Company field of manage tour page contain lead company name ?");
        passedLogs = @objRollbar.addLog("[Expected]  Lead.Company= #{@leadsTestData[0]['company']} \n[Result  ]  Success")
        
        #puts "[Validate] Does Company field of manage tour page contain lead company name ? "
        #puts "[Expected] Lead.Company= #{@leadsTestData[0]['company']}"
        #puts "[Result]   Success"
        puts "\n"
      end

      if !@driver.find_elements(:id,"Email").empty? then
        expect(@driver.find_element(:id,"Email").attribute('value').eql? "").to be false
        expect(@driver.find_element(:id,"Email").attribute('value').eql? "#{@leadsTestData[0]['email']}")
        passedLogs = @objRollbar.addLog("[Validate]  Does Email field of manage tour page contain lead email id ? ");
        passedLogs = @objRollbar.addLog("[Expected]  Lead.Email= #{@leadsTestData[0]['email']} \n[Result  ]  Success")

        #puts "[Validate] Does Email field of manage tour page contain lead email id ? "
        #puts "[Expected] Lead.Email= #{@leadsTestData[0]['email']}"
        #puts "[Result]   Success"
        puts "\n"
      end

      #puts "C91 : successfully checked\n"
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
  it "C85: To check user can view duplicate account selector page while booking a tour" do
    #puts "C85,C171 : to check that user can view duplicate account selector page while booking a tour and user can book a tour"
    puts "C85: To check user can view duplicate account selector page while booking a tour and user can book a tour"
    puts "\n"
    begin
      caseInfo = @testRailUtility.getCase('85')
       passedLogs = @objRollbar.addLog("[Step]     Duplicate account selector pop-up should be opened", caseInfo['id'])
        #puts "[step]     Duplicate account selector pop-up should be opened"
        @objManageTours.bookTour(0,true)
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        puts "#{@driver.find_element(:id,"header43").text} opened successfully"
        puts "\n"
        EnziUIUtility.wait(@driver,:id,"header43",@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        expect(@driver.find_element(:id,"header43").text.eql? "Duplicate Account Selector").to be true
        
        passedLogs = @objRollbar.addLog("[Expected]  Duplicate account selector pop up is displayed \n[Result  ]  Success")
        #puts "[Expected] Duplicate account selector pop up is displayed"
        #puts "[Result]   Success"
     # puts "C85 : successfully checked"
        puts "\n"
        passedLogs = @objRollbar.addLog("[Step    ]  Adding result in testrail")
        @testRailUtility.postResult(85,"Result for case 85 is #{"success"}",1,@runId)
        passedLogs = @objRollbar.addLog("[Result  ]  Success")
      #@objManageTours.getAllData(false).values
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
    it "C86 : To check tour is booked, when user clicks on 'create account and don't merge' button" do
      puts "C86 : To check tour is booked, when user clicks on 'create account and don't merge' button"
      puts "\n"
      begin
        caseInfo = @testRailUtility.getCase('86')
        
        puts "\n"
        EnziUIUtility.wait(@driver,:id,"enzi-data-table-container",@objManageTours.instance_variable_get(:@timeSettingMap)['Wait']['Environment']['Lightening'])
        @objManageTours.duplicateAccountSelector("Create Account and Don't Merge",nil)
        leadName = "#{@objManageTours.instance_variable_get(:@records)[0]['lead'][0]['firstName']}#{@objManageTours.instance_variable_get(:@records)[0]['lead'][0]['lastName']}"
        
        passedLogs = @objRollbar.addLog("[Step    ]  #{leadName} named lead should be converted",caseInfo['id'])

        #puts  "[Step]    #{leadName} named lead should be converted"
        expect(@objManageTours.checkRecordCreated("Lead","SELECT id,isConverted FROM Lead WHERE Email = '#{@leadsTestData[0]['email']}'")[0].fetch("IsConverted").eql? 'true').to be true
        passedLogs = @objRollbar.addLog("[Expected]  Successfully lead is converted \n[Result  ]  Success")
        #puts "[Expected] Successfully lead is converted "
        #puts "[Result]   Success"
        puts "\n"
        passedLogs = @objRollbar.addLog("[Step    ]  Contact Should be created with name #{leadName}")
        #puts "[Step]     Contact Should be created with name #{leadName}"
        expect(@objManageTours.checkRecordCreated("Contact","SELECT id,total_Scheduled_Tours__c FROM Contact WHERE Email = '#{@leadsTestData[0]['email']}'")[0].fetch("Id")).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected]  Successfully contact is created \n[Result  ]  Success")
        #puts "[Expected] Successfully contact is created"
        #puts "[Result]   Success"
        puts "\n"
        
        passedLogs = @objRollbar.addLog("[Step    ]  Account Should be created with name #{@leadsTestData[0]['company']}")
        #puts "[Step]     Account Should be created with name #{@leadsTestData[0]['company']}"
        expect(@objManageTours.checkRecordCreated("Account","SELECT id,allow_merge__c FROM Account WHERE name = '#{@leadsTestData[0]['company']}'")[0].fetch("Id")).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected]  Successfully account is created \n[Result  ]  Success")
        #puts "[Expected] Successfully account is created"
        #puts "[Result]   Success"
        puts "\n"

      
        sleep(30)
        createdOpportunity = @objManageTours.checkRecordCreated("Opportunity","SELECT id,name FROM Opportunity WHERE Account.name = '#{@leadsTestData[0]['company']}'")[0]
         passedLogs = @objRollbar.addLog("[Step    ]  Opportunity should be created with name #{createdOpportunity.fetch("Name")}")
        #puts "[Step]     Opportunity should be created with name #{createdOpportunity.fetch("Name")}"
        expect(createdOpportunity.fetch("Id")).to_not eql nil
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        passedLogs = @objRollbar.addLog("[Expected]  Successfully opportunity is created \n[Result  ]  Success")
        #puts "[Expected] Successfully opportunity is created"
        #puts "[Result]   Success"
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ]  Checking allow merge field on account \n[Validate]  Does Allow Merge field on account is unchecked?")
        #puts "[Step]     Checking allow merge field on account "
        #puts "[Validate] Does Allow Merge field on account is unchecked?"
        expect(ManageTours.class_variable_get(:@@recordInsertedIds)['Account'].fetch('Allow_Merge__c').eql? 'false').to be true
        passedLogs = @objRollbar.addLog("[Expected]  Allow merge = #{ManageTours.class_variable_get(:@@recordInsertedIds)['Account'].fetch('Allow_Merge__c')}\t \n[Result  ]  Success")
        #puts "[Expected] Allow merge = #{ManageTours.class_variable_get(:@@recordInsertedIds)['Account'].fetch('Allow_Merge__c')}\t\n"
        #puts "[Result]   Success"
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ]  Checking total number of scheduled tours on contact \n[Validate]  Does Total number of scheduled tours field of contact updated after tour booking?")
        #puts "[Step]     Checking total number of scheduled tours on contact"
        #puts "[Validate] Does Total number of scheduled tours field of contact updated after tour booking?"
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        expect(ManageTours.class_variable_get(:@@recordInsertedIds)['Contact'].fetch('Total_Scheduled_Tours__c').to_i > 0).to be true
        passedLogs = @objRollbar.addLog("[Expected]  Total number of scheduled tours = #{ManageTours.class_variable_get(:@@recordInsertedIds)['Contact'].fetch('Total_Scheduled_Tours__c')}\t \n[Result  ]  Success")
        #puts "[Expected] Total number of scheduled tours = #{ManageTours.class_variable_get(:@@recordInsertedIds)['Contact'].fetch('Total_Scheduled_Tours__c')}\t\n"
        #puts "[Result]   Success"
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ]  Tour should be created")
        #puts "[Step]     Tour should be created"
        expect(@objManageTours.checkRecordCreated("Tour_Outcome__c","SELECT id,Status__c FROM Tour_Outcome__c WHERE Primary_Member__r.email = '#{@leadsTestData[0]['email']}'")[0].fetch("Id")).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected]  Successfully tour is created \n[Result  ]  Success")
        #puts "[Expected] Successfully tour is created "
        #puts "[Result]   Success"
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ]  Success message for booked tour should be displayed \n[Expected]  Success Message as 'Tour booked successfully and will be synced shortly' and 'Tours synced successfully' should be displayed \n[Result  ]  Success")
        #puts "[Step]     Success message for booked tour should be displayed"
        #puts "[Expected] Success Message as 'Tour booked successfully and will be synced shortly' and 'Tours synced successfully' should be displayed"
        #puts "[Result]   Success"
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ]  To check status of created tour \n[Validate]  Does status of tour updated as 'Scheduled' ?")
        #puts "[Step]     To check status of created tour"
        #puts "[Validate] Does status of tour updated as 'Scheduled' ?"
        expect(ManageTours.class_variable_get(:@@recordInsertedIds)['Tour_Outcome__c'].fetch('Status__c').eql? "Scheduled").to be true
        passedLogs = @objRollbar.addLog("[Expected]  Status= #{ManageTours.class_variable_get(:@@recordInsertedIds)['Tour_Outcome__c'].fetch('Status__c')} \n[Result  ]  Success")
        #puts "[Expected] Status= #{ManageTours.class_variable_get(:@@recordInsertedIds)['Tour_Outcome__c'].fetch('Status__c')}"
        #puts "[Result]   Success"
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ]  Activity should be created for tour")
        #puts "[Step]     Activity should be created for tour"
        expect(@objManageTours.checkRecordCreated('Task',"SELECT id FROM Task WHERE whatId = '#{ManageTours.class_variable_get(:@@recordInsertedIds)['Tour_Outcome__c'].fetch('Id')}'")[0].fetch('Id')).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected]  'Book a tour' activity is created \n[Result  ]  Success")
        #puts "[Expected] 'Book a tour' activity is created"
        #puts "[Result]   Success"
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
    it "C89 : To check user can view booked tours information" do
      puts "C89 : To check user can view booked tours information"
      puts "\n"
      begin
        caseInfo = @testRailUtility.getCase('89')
        passedLogs = @objRollbar.addLog("[Step    ]  Checking booked tour information", caseInfo['id'])
        #puts "[Step]     Checking booked tour information"
        expect(@objManageTours.numberOfTourBooked == 3).to be true
        passedLogs = @objRollbar.addLog("[Expected]  Tour records are displayed on same manage tour page \n[Result  ]  Success")
        #puts "[Expected] Tour information is displayed on same manage tour page"
        #puts "C89 : successfully checked"
        #puts "[Result]   Success"
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
      it "C96 : To check user can book multiple tour" do
        puts "C96 : To check user can book multiple tour"
        puts "\n"
        begin
          caseInfo = @testRailUtility.getCase('96')
          passedLogs = @objRollbar.addLog("[Step    ]  Multiple tours should be booked", caseInfo['id'])
        #puts "[Step]     Multiple tours should be booked"
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        @objManageTours.bookNewTour
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        @objManageTours.bookTour(0,true)
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        @objManageTours.bookTour(1,true)
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        @objManageTours.duplicateAccountSelector("Create Account and Don't Merge",nil)
        sleep(30)
        bookedTours = @objManageTours.checkRecordCreated("Tour_Outcome__c","SELECT id,Status__c FROM Tour_Outcome__c WHERE Primary_Member__r.email = '#{@leadsTestData[0]['email']}'")
          
        
        expect(bookedTours.size > 1).to be true

        passedLogs = @objRollbar.addLog("[Expected]  Multiple tours are booked and those are = #{bookedTours.inspect} \n[Result  ]  Success")
        #puts "[Expected] Multiple tours are booked and those are =>  #{bookedTours.inspect}\t\n"
        #puts "[Result]   Success"
        puts "\n"
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        
        passedLogs = @objRollbar.addLog("[Step    ]  Open activities for tours should be created")
        #puts "[Step]     Open activities for tours should be created"
        expect(@objManageTours.checkRecordCreated('Task',"SELECT id FROM Task WHERE whatId = '#{bookedTours[0].fetch('Id')}'")[0].fetch('Id')).to_not eql nil
        expect(@objManageTours.checkRecordCreated('Task',"SELECT id FROM Task WHERE whatId = '#{bookedTours[1].fetch('Id')}'")[0].fetch('Id')).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected]  Open activities are created for multiple tours \n[Result  ]  Success")
        #puts "[Expected] Open activities are created for multiple tours"
        #puts "[Result]   Success"
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ]  User should see booked tour information")
        #puts "[Step]     User should see booked tour information"
        expect(@objManageTours.numberOfTourBooked > 3).to be true
        passedLogs = @objRollbar.addLog("[Expected]  Booked tours records are available on manage tour page \n[Result  ]  Success")
        #puts "[Expected] Booked tours records are available on manage tour page"
        #puts "[Result]   Success"
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
    it "C94 : To check tour is booked, when user clicks on 'create account and merge' button" do
      puts "C94 : To check tour is booked, when user clicks on 'create account and merge' button"
      puts "\n"
      begin
        caseInfo = @testRailUtility.getCase('94')
        

        
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        @leadsTestData[0]['email'] = "test_enzigmaPre#{rand(9999)}@example.com"
        @leadsTestData[0]['company'] = "Test_Enzigma#{rand(1111)}"
        puts "\n"
        
        @objManageTours.openPageForLead(Salesforce.createRecords(@objManageTours.instance_variable_get(:@salesforceBulk),'Lead',@leadsTestData)[0]['Id'])
        @objManageTours.checkRecordCreated("Journey__c","SELECT id FROM Journey__c WHERE Primary_Email__c = '#{@leadsTestData[0]['email']}'")[0].fetch('Id')
        @objManageTours.bookTour(0,true)
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        @objManageTours.duplicateAccountSelector("Create Account and Merge",nil)
         
        #puts "[Step]     Lead with #{@leadsTestData[0]['email']} email id should be converted"
        passedLogs = @objRollbar.addLog("[Step    ]  Lead with #{@leadsTestData[0]['email']} email id should be converted",caseInfo['id'])
        #puts "\n"
        expect(@objManageTours.checkRecordCreated("Lead","SELECT id,isConverted FROM Lead WHERE Email = '#{@leadsTestData[0]['email']}'")[0].fetch("IsConverted").eql? 'true').to be true
        passedLogs = @objRollbar.addLog("[Expected]  Lead converted Sucessfully \n[Result  ]  Success")
        #puts "[Expected] Lead converted Sucessfully"
        #puts "[Result]   Success"
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ]  Contact should be created with name #{leadName}")
        #puts "[Step]     Contact should be created with name #leadName"
        expect(@objManageTours.checkRecordCreated("Contact","SELECT id,total_Scheduled_Tours__c FROM Contact WHERE Email = '#{@leadsTestData[0]['email']}'")[0].fetch("Id")).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected]  Contact created successfully \n[[Result  ]  Success")
        #puts "[Expected] Contact created successfully"
        #puts "[Result]   Success"
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ]  Account should be created with name #{@leadsTestData[0]['company']}")
        #puts "[Step]     Account should be created with name #{@leadsTestData[0]['company']}"
        expect(@objManageTours.checkRecordCreated("Account","SELECT id,allow_merge__c FROM Account WHERE name = '#{@leadsTestData[0]['company']}'")[0].fetch("Id")).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected]  Account created successfully \n[Result  ]  Success")
        #puts "[Expected] Account created successfully"
        #puts "[Result]   Success"
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ]  Opportunity should be created")
        #puts "[Step]     Opportunity should be created"
        sleep(30)
        expect(@objManageTours.checkRecordCreated("Opportunity","SELECT id FROM Opportunity WHERE Account.name = '#{@leadsTestData[0]['company']}'")[0].fetch("Id")).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected]  Opportunity created successfully \n[Result  ]  Success")
        #puts "[Expected] Opportunity created successfully"
        #puts "[Result]   Success"
        puts "\n"

        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        
        passedLogs = @objRollbar.addLog("[Step    ]  To check allow merge field on account \n[Validate]  Does Allow Merge field on account is checked?")
        #puts "[Step]     To check allow merge field on account "
        #puts "[Validate] Does Allow Merge field on account is checked?"
        expect(ManageTours.class_variable_get(:@@recordInsertedIds)['Account'].fetch('Allow_Merge__c').eql? 'true').to be true
        passedLogs = @objRollbar.addLog("[Expected]  Allow merge status = #{ManageTours.class_variable_get(:@@recordInsertedIds)['Account'].fetch('Allow_Merge__c')}\t \n[Result  ]  Success")
        #puts "[Expected] Allow merge status = #{ManageTours.class_variable_get(:@@recordInsertedIds)['Account'].fetch('Allow_Merge__c')}\t\n"
        #puts "[Result]   Success"
        puts"\n"

        passedLogs = @objRollbar.addLog("[Step    ]  Checking total number of scheduled tours on contact \n[Validate]  Does Total number of scheduled tours field of contact updated after tour booking?")
        #puts "[Step]     Checking total number of scheduled tours on contact"
        #puts "[Validate] Does Total number of scheduled tours field of contact updated after tour booking?"

        expect(ManageTours.class_variable_get(:@@recordInsertedIds)['Contact'].fetch('Total_Scheduled_Tours__c').to_i > 0).to be true
        passedLogs = @objRollbar.addLog("[Expected]  Total number of scheduled tours = #{ManageTours.class_variable_get(:@@recordInsertedIds)['Contact'].fetch('Total_Scheduled_Tours__c')}\t \n[Result  ]  Success")

        #puts "[Expected] Total number of scheduled tours => #{ManageTours.class_variable_get(:@@recordInsertedIds)['Contact'].fetch('Total_Scheduled_Tours__c')}\t\n"
        #puts "[Result]   Success"
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ]  Tour should be created")
        #puts "[Step]     Tour should be created"
        expect(@objManageTours.checkRecordCreated("Tour_Outcome__c","SELECT id,Status__c FROM Tour_Outcome__c WHERE Primary_Member__r.email = '#{@leadsTestData[0]['email']}'")[0].fetch("Id")).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected]  Tour created successfully \n[Result  ]  Success")
        #puts "[Expected] Tour created successfully"
        #puts "[Result]   Success"
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ]  Success message for booked tour should be displayed \n[Expected]  Success Message as 'Tour booked successfully and will be synced shortly' and 'Tours synced successfully' should be displayed \n[Result  ]  Success")
        #puts "[Step]     Success message for booked tour should be displayed"
        #puts "[Expected] Success Message as 'Tour booked successfully and will be synced shortly' and 'Tours synced successfully' should be displayed"
        #puts "[Result]   Success"
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ]  To check status of created tour \n[Validate]  Does status of tour updated as 'Scheduled' ?")
        #puts "[Step]     To check status of created tour"
        #puts "[Validate] Does status of tour updated as 'Scheduled' ?"
        expect(ManageTours.class_variable_get(:@@recordInsertedIds)['Tour_Outcome__c'].fetch('Status__c').eql? "Scheduled").to be true
        passedLogs = @objRollbar.addLog("[Expected]  Status =Scheduled \n[Result  ]  Success")
        #puts "[Expected] Status =Scheduled"
        #puts "[Result]   Success"
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ]  Checking open activities")
        #puts "[Step]     Checking open activities"
        expect(@objManageTours.checkRecordCreated('Task',"SELECT id FROM Task WHERE whatId = '#{ManageTours.class_variable_get(:@@recordInsertedIds)['Tour_Outcome__c'].fetch('Id')}'")[0].fetch('Id')).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected]  'Book a tour' named open activity created successfully \n[Result  ]  Success")
        #puts "[Expected] 'Book a tour' named open activity created successfully"
        #puts "[Result]   Success"
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ]  User should see records of booked tour")
        #puts "[Step]     User should see records of booked tour "
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        expect(@objManageTours.numberOfTourBooked == 3).to be true
        passedLogs = @objRollbar.addLog("[Expected]  Booked tours records are available on manage tour page \n[Result  ]  Success")
        #puts "[Expected] Booked tours records are available on manage tour page"
        #puts "[Result]   Success"
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
    it "C129 : to check user can cancel a tour"  , :test => true do
      puts "C129 : to check user can cancel a tour"
      puts "\n"
      begin
        caseInfo = @testRailUtility.getCase('129')
        passedLogs = @objRollbar.addLog("[Step    ]  User can fill cancellation reason \n[validate]  Does cancel tour pop-up accept cancellation reason ? ", caseInfo['id'])

        #puts "[Step]     User can fill cancellation reason"
        #puts "[validate] Does cancel tour pop-up accept cancellation reason ? "
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        EnziUIUtility.selectElement(@driver,"Cancel","button")
        EnziUIUtility.wait(@driver,:id,"header43",@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        EnziUIUtility.selectChild(@driver,:id,"Cancellation_Reason__c","No reason (didn't provide)","option")
        passedLogs = @objRollbar.addLog("[Expected]  Cancellation Reason= No reason \n[Result  ]  Success")
        #puts "[Expected] Cancellation Reason= No reason"
        #puts "[Result]   Success"
        puts "\n"

        passedLogs = @objRollbar.addLog("[validate]  Does save button get enabled after filling out cancellation reason ? ")
        #puts "[validate] Does save button get enabled after filling out cancellation reason ? "
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        EnziUIUtility.selectElement(@driver,"Save","button")
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        passedLogs = @objRollbar.addLog("[Expected]  Save button get enabled \n[Result  ]  Success")
        #puts "[Expected] Save button get enabled"
        #puts "[Result]   Success"
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate]  Does status of tour change after cancellation of tour")
        #puts "[Validate] Does status of tour change after cancellation of tour"
        expect(@objManageTours.tourStatusChecked?("Cancelled" , @leadsTestData[0]['email'])).to be true
        passedLogs = @objRollbar.addLog("[Expected]  Tour status=Cancelled \n[Result  ]  Success")
        #puts "[Expected] Tour status=Cancelled"
        #puts "[Result]   Success"
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
    it "C102 : to check that tour is booked, when user clicks on 'Use Selector Account' button" , :test => true do
      puts "C102 : to check that tour is booked, when user clicks on 'Use Selector Account' button"
      puts "\n"
      begin
        caseInfo = @testRailUtility.getCase('102')
        passedLogs = @objRollbar.addLog("[Step    ]  Lead with #{@leadsTestData[0]['email']} email id should be converted", caseInfo['id'])
       

        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        @leadsTestData[0]['email'] = "test_enzigmaPre#{rand(9999)}@example.com"
        @objManageTours.openPageForLead(Salesforce.createRecords(@objManageTours.instance_variable_get(:@salesforceBulk),'Lead',@leadsTestData)[0]['Id'])
        #@objManageTours.openPage(Salesforce.createRecords(@objManageTours.instance_variable_get(:@salesforceBulk),'Lead',@leadsTestData)[0]['Id'],:name,"lightning_manage_tours")
        @objManageTours.checkRecordCreated("Journey__c","SELECT id FROM Journey__c WHERE Primary_Email__c = '#{@leadsTestData[0]['email']}'")[0].fetch('Id')
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        @objManageTours.bookTour(0,true)
        @objManageTours.duplicateAccountSelector("Use Selected Account","Yes")
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        
        #puts "[Step]     Lead with #{@leadsTestData[0]['email']} email id should be converted"
        expect(@objManageTours.checkRecordCreated("Lead","SELECT id,isConverted FROM Lead WHERE Email = '#{@leadsTestData[0]['email']}'")[0].fetch("IsConverted").eql? 'true').to be true
        passedLogs = @objRollbar.addLog("[Expected]  Lead converted Sucessfully \n[Result  ]  Success")
        #puts "[Expected] Lead converted Sucessfully"
        #puts "[Result]   Success"
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ]  Contact should be created")
        #puts "[Step]     Contact should be created with name #leadName"
        expect(@objManageTours.checkRecordCreated("Contact","SELECT id,Account.name FROM Contact WHERE Email = '#{@leadsTestData[0]['email']}'")[0].fetch("Id")).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected]  Contact created successfully \n[Result  ]  Success")
        #puts "[Expected] Contact created successfully"
        #puts "[Result]   Success"
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ]  Tour should be created")
        #puts "[Step]     Tour should be created"
        expect(@objManageTours.checkRecordCreated("Tour_Outcome__c","SELECT id,Status__c FROM Tour_Outcome__c WHERE Primary_Member__r.email = '#{@leadsTestData[0]['email']}'")[0].fetch("Id")).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected]  Tour created successfully \n[Result  ]  Success")
        #puts "[Expected] Tour created successfully"
        #puts "[Result]   Success"
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ]  Success message for booked tour should be displayed \n[Expected]  Success Message as 'Tour booked successfully and will be synced shortly' and 'Tours synced successfully' should be displayed \n[Result  ]  Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ]  To check status of created tour \n[Validate]  Does status of tour updated as 'Scheduled' ?")
        #puts "[Step]     To check status of created tour"
        #puts "[Validate] Does status of tour updated as 'Scheduled' ?"
        expect(ManageTours.class_variable_get(:@@recordInsertedIds)['Tour_Outcome__c'].fetch('Status__c').eql? "Scheduled").to be true
        #puts "Tour outcome id ::"+ManageTours.class_variable_get(:@@recordInsertedIds)['Tour_Outcome__c'].fetch('Id')
        #puts "Tour status checked successfully"
        #puts "\n"
        passedLogs = @objRollbar.addLog("[Expected]  Status = #{ManageTours.class_variable_get(:@@recordInsertedIds)["Tour_Outcome__c"].fetch("Status__c")} \n[Result  ]  Success")
        #puts "[Expected] Status = #{ManageTours.class_variable_get(:@@recordInsertedIds)["Tour_Outcome__c"].fetch("Status__c")}"
        #puts "[Result]   Success"
        puts "\n"
        #sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        #if ManageTours.class_variable_get(:@@recordInsertedIds)['Account'].fetch('Number_Of_Open_Opportunities__c').eql? 0 then
        #expect(@objManageTours.checkRecordCreated("Opportunity","SELECT id FROM Opportunity WHERE Account.email = '#{@objManageTours.instance_variable_get(:@records)[2]['existingAccount']['email']}'")[0].fetch("Id")).to_not eql nil
        #else
        #expect(@objManageTours.checkRecordCreated("Opportunity","SELECT id FROM Opportunity WHERE Account.email = '#{@objManageTours.instance_variable_get(:@records)[2]['existingAccount']['email']}'")[0]).to eql nil
        #end
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        passedLogs = @objRollbar.addLog("[Step    ]  Checking open activities")
        #puts "[Step]     Checking open activities"
        expect(@objManageTours.checkRecordCreated('Task',"SELECT id FROM Task WHERE whatId = '#{ManageTours.class_variable_get(:@@recordInsertedIds)['Tour_Outcome__c'].fetch('Id')}'")[0].fetch('Id')).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected]  'Book a tour' named open activity created successfully \n[Result  ]  Success")
        #puts "[Expected] 'Book a tour' named open activity created successfully"
        #puts "[Result]   Success"
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ]  User should see records of booked tour")
        #puts "[Step]     User should see records of booked tour "
        expect(@objManageTours.numberOfTourBooked == 3).to be true
        passedLogs = @objRollbar.addLog("[Expected]  Booked tours records are available on manage tour page \n[Result  ]  Success")
        #puts "[Expected] Booked tours records are available on manage tour page"
        #puts "[Result]   Success"
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
    it "C115 : To check user can reschedule a tour" , :test => true do
      puts "C115 : To check user can reschedule a tour"
      puts "\n"
      begin
        caseInfo = @testRailUtility.getCase('115')
        passedLogs = @objRollbar.addLog("[Step    ]  Check status of tour after rescheduling \n[Validate]  Does status of tour updated as Rescheduled ?", caseInfo['id'])
        
        puts "\n"

        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        @leadsTestData[0]['email'] = "test_enzigmaPre#{rand(9999)}@example.com"
        @leadsTestData[0]['company'] = "Test_Enzigma#{rand(1111)}"
        @objManageTours.openPageForLead(Salesforce.createRecords(@objManageTours.instance_variable_get(:@salesforceBulk),'Lead',@leadsTestData)[0]['Id'])
        #@objManageTours.openPage(Salesforce.createRecords(@objManageTours.instance_variable_get(:@salesforceBulk),'Lead',@leadsTestData)[0]['Id'],:name,"lightning_manage_tours")
        @objManageTours.checkRecordCreated("Journey__c","SELECT id FROM Journey__c WHERE Primary_Email__c = '#{@leadsTestData[0]['email']}'")
        @objManageTours.bookTour(0,true)
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        @objManageTours.duplicateAccountSelector("Create Account and Don't Merge",nil)
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])

        #puts "[Step]     Check status of tour after rescheduling"
        #puts "[Validate] Does status of tour updated as Rescheduled ?"
        @objManageTours.rescheduleTour
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        expect(@objManageTours.tourStatusChecked?("Rescheduled" , @leadsTestData[0]['email'])).to be true
       
        passedLogs = @objRollbar.addLog("[Expected]  Status = Rescheduled \n[Result  ]  Success")
        #puts "[Expected] Status = Rescheduled"
        #puts "[Result]   Success"
        
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
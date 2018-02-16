#Created By : Monika Pingale
#Created Date : 28/12/2017
#Modified date : 31/01/2018
require_relative File.expand_path(Dir.pwd+"/ManageTourPageTest/Src/pageObjects/manageTours(Staging).rb")
require_relative File.expand_path("GemUtilities/EnziTestRailUtility/lib/EnziTestRailUtility.rb")
require "selenium-webdriver"
require "rspec"
require 'enziUIUtility'
require 'date'
#require_relative "helper.rb"
require 'saucelabs'
describe ManageTours do
  before(:all){
    include SauceLabs
    #SauceLab will read env variable and accordingly set browser
    @driver = SauceLabs.selenium_driver()
    #@driver = Selenium::WebDriver.for :chrome
    @objManageTours = ManageTours.new(@driver,"Staging")
    @leadsTestData = @objManageTours.instance_variable_get(:@records)[0]['lead']
    @testRailUtility = EnziTestRailUtility::TestRailUtility.new(@objManageTours.instance_variable_get(:@mapCredentials)['TestRail']['username'],@objManageTours.instance_variable_get(:@mapCredentials)['TestRail']['password'])
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
    @runId = @testRailUtility.addRun("Manage Tour by lead",4,19,arrCaseIds)['id']
  }

  after(:all){
    allRecordIds = Salesforce.class_variable_get(:@@createdRecordsIds)
    puts "Records to delete :: #{allRecordIds}"
    #Salesforce.deleteRecords(@objManageTours.instance_variable_get(:@salesforceBulk),"Journey__c",[@objManageTours.instance_variable_get(:@recordInsertedIdsToDelete)['Journey__c']['Id']])
    Salesforce.deleteRecords(@objManageTours.instance_variable_get(:@salesforceBulk),"Journey__c",allRecordIds['Journey__c'])
    Salesforce.deleteRecords(@objManageTours.instance_variable_get(:@salesforceBulk),"Tour_Outcome__c",allRecordIds['Tour_Outcome__c'])
    Salesforce.deleteRecords(@objManageTours.instance_variable_get(:@salesforceBulk),"Opportunity",allRecordIds['Opportunity'])
    Salesforce.deleteRecords(@objManageTours.instance_variable_get(:@salesforceBulk),"Lead",allRecordIds['Lead'])
    Salesforce.deleteRecords(@objManageTours.instance_variable_get(:@salesforceBulk),"Account",allRecordIds['Account'])
    Salesforce.deleteRecords(@objManageTours.instance_variable_get(:@salesforceBulk),"Contact",allRecordIds['Contact'])

    @driver.quit
  }
  it "C149 : to check manage tour page is displayed" , :test => true do
    begin
      @leadsTestData[0]['email'] = "test_enzigmaPre#{rand(9999)}@example.com"
      @leadsTestData[0]['company'] = "Test_Enzigma#{rand(1111)}"
      puts "check for manage tour page opened"
      puts "\n"
      @objManageTours.openPage(Salesforce.createRecords(@objManageTours.instance_variable_get(:@salesforceBulk),'Lead',@leadsTestData)[0]['Id'],:name,"lightning_manage_tours")

      #@objManageTours.openPage(@objManageTours.checkRecordCreated("Journey__c","SELECT id FROM Journey__c WHERE Primary_Email__c = '#{@objManageTours.instance_variable_get(:@records)[0]['lead'][0]['email']}'")[0].fetch('Id'),:id,"taction:0")
      Salesforce.addRecordsToDelete('Journey__c',@objManageTours.checkRecordCreated("Journey__c","SELECT id FROM Journey__c WHERE Primary_Email__c = '#{@leadsTestData[0]['email']}'")[0].fetch('Id'))
      expect(@driver.title).to eql "Manage Tours"
      puts "successfully opened manage tour page C149 checked"
      puts "\n"
      @testRailUtility.postResult(149,"Result for case 149 is #{"success"}",1,@runId)
    rescue Exception => excp
      @testRailUtility.postResult(149,"Result for case 149 is #{excp}",5,@runId)
      raise excp
    end
  end

  it "C883 : to check that book tour button is disabled" do
    puts "C883 : to check that book tour button is disabled"
    begin
      puts "\n"
      expect(@objManageTours.buttonDisabled?).to be true
      puts "C883 checked"
      @testRailUtility.postResult(883,"Result for case 883 is #{"success"}",1,@runId)
    rescue Exception => excp
      @testRailUtility.postResult(883,"Result for case 883 is #{excp}",5,@runId)
      raise excp
    end

  end

  it "C7 : to check that book tour button get enable" do
    puts "C7 : to check that book tour button get enable"
    puts "\n"
    begin
      @objManageTours.bookTour(0,false)
      sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
      expect(@objManageTours.buttonDisabled?).to be true
      puts "C7 checked"
      puts "\n"
      @testRailUtility.postResult(7,"Result for case 7 is #{"success"}",1,@runId)
    rescue Exception => excp
      @testRailUtility.postResult(7,"Result for case 7 is #{excp}",5,@runId)
      raise excp
    end
  end

  it "C885 : to check that user can select tour date without building name", :regression => true do
    puts "C885  : to check that user can select tour date without building name"
    puts "\n"
    begin
      sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
      expect(@objManageTours.childDisabled?(ManageTours.selectBuilding(@driver.find_element(:id,"BookTours0"),nil,@objManageTours.instance_variable_get(:@timeSettingMap)),ManageTours.selectTourDate(@driver.find_element(:id,"BookTours0"),@objManageTours.instance_variable_get(:@timeSettingMap)))).to be false
      puts "C885  checked"
      puts "\n"
      @testRailUtility.postResult(885 ,"Result for case 885  is #{"success"}",1,@runId)
    rescue Exception => excp
      @testRailUtility.postResult(885 ,"Result for case 885  is #{excp}",5,@runId)
      raise excp
    end
  end
  it "C81 : to check that user can select start time"  do
    puts "C81 : to check that user can select start time"
    puts "\n"
    begin
      ManageTours.selectBuilding(@driver.find_element(:id,"BookTours0"),"LA-Santa Monica",@objManageTours.instance_variable_get(:@timeSettingMap))
      ManageTours.selectTourDate(@driver.find_element(:id,"BookTours0"),@objManageTours.instance_variable_get(:@timeSettingMap))
      #EnziUIUtility.clickElement(@driver,:id,"1517855400000")
      EnziUIUtility.selectElement(@driver.find_element(:id,"BookTours0"),"Today","a")
      sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
      expect(@objManageTours.childDisabled?(ManageTours.selectTourDate(@driver.find_element(:id,"BookTours0"),@objManageTours.instance_variable_get(:@timeSettingMap)),ManageTours.setElementValue(@driver.find_element(:id,"BookTours0"),"startTime",nil))).to be false
      puts "C81 checked"
      puts "\n"
      @testRailUtility.postResult(81,"Result for case 81 is #{"success"}",1,@runId)
    rescue Exception => excp
      @testRailUtility.postResult(81,"Result for case 81 is #{excp}",5,@runId)
      raise excp
    end
  end
  it "C887 : to check that user can get end time automatically after entering start time" do
    puts "C887 : to check that user can get end time automatically after entering start time"
    puts "\n"
    begin
      ManageTours.setElementValue(@driver.find_element(:id,"BookTours0"),"startTime",nil)
      sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
      expect(ManageTours.getElement("input","endTime",@driver.find_element(:id,"BookTours0"))).to_not eql nil
      puts "C887 checked"
      puts "\n"
      @testRailUtility.postResult(887,"Result for case 887 is #{"success"}",1,@runId)
    rescue Exception => excp
      @testRailUtility.postResult(887,"Result for case 887 is #{excp}",5,@runId)
      raise excp
    end
  end
  it "C92 : to check that proper error message is displayed when user enter single character in building field" do
    puts "C92 : to check that proper error message is displayed when user enter single character in building field"
    puts "\n"
    begin
      ManageTours.selectBuilding(@driver.find_element(:id,"BookTours0"),nil,@objManageTours.instance_variable_get(:@timeSettingMap)).clear
      #ManageTours.selectBuilding(@driver.find_element(:id,"BookTours0"),nil).send_keys "a"
      if ManageTours.selectBuilding(@driver.find_element(:id,"BookTours0"),nil,@objManageTours.instance_variable_get(:@timeSettingMap)).attribute('value').length > 2 then
        expect(@driver.find_element(:xpath ,"//span[starts-with(@id, 'lookup-option')]").text).to eql nil
        puts "C92 checked"
        puts "\n"
      else
        expect(@driver.find_element(:xpath ,"//span[starts-with(@id, 'lookup-option')]")).to_not eql nil
      end
      @testRailUtility.postResult(92,"Result for case 92 is #{"success"}",1,@runId)
    rescue Exception => excp
      @testRailUtility.postResult(92,"Result for case 92 is #{excp}",5,@runId)
      raise excp
    end
    #ManageTours.selectBuilding(@driver.find_element(:id,"BookTours0"),nil).clear
  end
  it "C91 : to check that proper lead information is displayed on manage tour page" do
    puts "C91 : to check that proper lead information is displayed on manage tour page"
    puts "\n"
    begin
      if !@driver.find_elements(:id,"Name").empty? then
        expect(@driver.find_element(:id,"Name").attribute('value').eql? "").to be false
        expect(@driver.find_element(:id,"Name").attribute('value').eql? "#{@objManageTours.instance_variable_get(:@records)[0]['lead'][0]['firstName']}#{@objManageTours.instance_variable_get(:@records)[0]['lead'][0]['lastName']}")
        puts "C91 checked\n"
      end
      if !@driver.find_elements(:id,"Company").empty? then
        expect(@driver.find_element(:id,"Company").attribute('value').eql? "").to be false
        expect(@driver.find_element(:id,"Company").attribute('value').eql? "#{@leadsTestData[0]['company']}")
        puts "C91 checked\n"
      end
      if !@driver.find_elements(:id,"Email").empty? then
        expect(@driver.find_element(:id,"Email").attribute('value').eql? "").to be false
        expect(@driver.find_element(:id,"Email").attribute('value').eql? "#{@leadsTestData[0]['email']}")
        puts "C91 checked\n"
      end
      puts "\n"
      @testRailUtility.postResult(91,"Result for case 91 is #{"success"}",1,@runId)
    rescue Exception => excp
      @testRailUtility.postResult(91,"Result for case 91 is #{excp}",5,@runId)
      raise excp
    end
  end
  it "C85,C171 : to check that user can view duplicate account selector page while booking a tour" do
    puts "C85,C171 : to check that user can view duplicate account selector page while booking a tour"
    puts "\n"
    begin
      @objManageTours.bookTour(0,true)
      sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
      puts "header is #{@driver.find_element(:id,"header43").text}"
      puts "\n"
      EnziUIUtility.wait(@driver,:id,"header43",@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
      expect(@driver.find_element(:id,"header43").text.eql? "Duplicate Account Selector").to be true
      puts "C85 checked"
      puts "\n"

      @testRailUtility.postResult(85,"Result for case 85 is #{"success"}",1,@runId)

    rescue Exception => excp
      @testRailUtility.postResult(85,"Result for case 85 is #{excp}",5,@runId)
      raise excp
    end
  end

  context "should test duplicate account selector functionality" do
    it "C86 : to check that tour is booked, when user clicks on 'create account and don't merge' button" do
      puts "C86 : to check that tour is booked, when user clicks on 'create account and don't merge' button"
      puts "\n"
      begin
        EnziUIUtility.wait(@driver,:id,"enzi-data-table-container",@objManageTours.instance_variable_get(:@timeSettingMap)['Wait']['Environment']['Lightening'])
        @objManageTours.duplicateAccountSelector("Create Account and Don't Merge",nil)
        puts "to check lead converted"
        puts "\n"
        expect(@objManageTours.checkRecordCreated("Lead","SELECT id,isConverted FROM Lead WHERE Email = '#{@leadsTestData[0]['email']}'")[0].fetch("IsConverted").eql? 'true').to be true
        puts "lead converted successfully"
        puts "\n"
        puts "to check contact created"
        puts "\n"
        expect(@objManageTours.checkRecordCreated("Contact","SELECT id,total_Scheduled_Tours__c FROM Contact WHERE Email = '#{@leadsTestData[0]['email']}'")[0].fetch("Id")).to_not eql nil
        puts "contact created successfully"
        puts "\n"
        puts "to check account created"
        puts "\n"
        expect(@objManageTours.checkRecordCreated("Account","SELECT id,allow_merge__c FROM Account WHERE name = '#{@leadsTestData[0]['company']}'")[0].fetch("Id")).to_not eql nil
        puts "account created successfully"
        puts "\n"
        puts "to check opportunity created"
        puts "\n"
        sleep(30)
        expect(@objManageTours.checkRecordCreated("Opportunity","SELECT id FROM Opportunity WHERE Account.name = '#{@leadsTestData[0]['company']}'")[0].fetch("Id")).to_not eql nil
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        puts "opportunity created successfully"
        puts "\n"
        puts "to check account allow merge"
        puts "\n"
        expect(ManageTours.class_variable_get(:@@recordInsertedIds)['Account'].fetch('Allow_Merge__c').eql? 'false').to be true
        puts "allow merge status is #{ManageTours.class_variable_get(:@@recordInsertedIds)['Account'].fetch('Allow_Merge__c')}\t\n"
        puts "to check total number of scheduled tours on contact"
        puts "\n"
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        expect(ManageTours.class_variable_get(:@@recordInsertedIds)['Contact'].fetch('Total_Scheduled_Tours__c').to_i > 0).to be true
        puts "total number of scheduled tours => #{ManageTours.class_variable_get(:@@recordInsertedIds)['Contact'].fetch('Total_Scheduled_Tours__c')}\t\n"
        puts "\n"
        puts "to check tour is created"
        puts "\n"
        expect(@objManageTours.checkRecordCreated("Tour_Outcome__c","SELECT id,Status__c FROM Tour_Outcome__c WHERE Primary_Member__r.email = '#{@leadsTestData[0]['email']}'")[0].fetch("Id")).to_not eql nil
        puts "tour creataed successfully"
        puts "\n"
        puts "to check tour status"
        puts "\n"
        expect(ManageTours.class_variable_get(:@@recordInsertedIds)['Tour_Outcome__c'].fetch('Status__c').eql? "Scheduled").to be true
        puts "status checked successfully"
        puts "\n"
        puts "to check open activities"
        expect(@objManageTours.checkRecordCreated('Task',"SELECT id FROM Task WHERE whatId = '#{ManageTours.class_variable_get(:@@recordInsertedIds)['Tour_Outcome__c'].fetch('Id')}'")[0].fetch('Id')).to_not eql nil
        puts "C86 checked"
        puts "\n"
        @testRailUtility.postResult(86,"Result for case 86 is #{"success"}",1,@runId)
      rescue Exception => excp
        @testRailUtility.postResult(86,"Result for case 86 is #{excp}",5,@runId)
        raise excp
      end
    end
    it "C89 : to check that user can view booked tours information" do
      puts "C89 : to check that user can view booked tours information"
      puts "\n"
      begin
        expect(@objManageTours.numberOfTourBooked == 3).to be true
        puts "C89 checked"
        puts "\n"
        @testRailUtility.postResult(89,"Result for case 89 is #{"success"}",1,@runId)
      rescue Exception => excp
        @testRailUtility.postResult(89,"Result for case 89 is #{excp}",5,@runId)
        raise excp
      end
    end

    it "C94,C362 : to check that tour is booked, when user clicks on 'create account and merge' button" do
      puts "C94,C362 : to check that tour is booked, when user clicks on 'create account and merge' button"
      puts "\n"
      begin
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        @leadsTestData[0]['email'] = "test_enzigmaPre#{rand(9999)}@example.com"
        @leadsTestData[0]['company'] = "Test_Enzigma#{rand(1111)}"
        puts "\n"
        @objManageTours.openPageForLead(Salesforce.createRecords(@objManageTours.instance_variable_get(:@salesforceBulk),'Lead',@leadsTestData)[0]['Id'])
        Salesforce.addRecordsToDelete('Journey__c',@objManageTours.checkRecordCreated("Journey__c","SELECT id FROM Journey__c WHERE Primary_Email__c = '#{@leadsTestData[0]['email']}'")[0].fetch('Id'))
        @objManageTours.bookTour(0,true)
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        @objManageTours.duplicateAccountSelector("Create Account and Merge",nil)
        puts "to check lead converted"
        puts "\n"
        expect(@objManageTours.checkRecordCreated("Lead","SELECT id,isConverted FROM Lead WHERE Email = '#{@leadsTestData[0]['email']}'")[0].fetch("IsConverted").eql? 'true').to be true
        puts "lead converted successfully"
        puts "\n"
        puts "to check contact created"
        puts "\n"
        expect(@objManageTours.checkRecordCreated("Contact","SELECT id,total_Scheduled_Tours__c FROM Contact WHERE Email = '#{@leadsTestData[0]['email']}'")[0].fetch("Id")).to_not eql nil
        puts "contact created successfully"
        puts "\n"
        puts "to check account created"
        puts "\n"
        expect(@objManageTours.checkRecordCreated("Account","SELECT id,allow_merge__c FROM Account WHERE name = '#{@leadsTestData[0]['company']}'")[0].fetch("Id")).to_not eql nil
        puts "account created successfully"
        puts "\n"
        puts "to check opportunity created"
        puts "\n"
        sleep(30)
        expect(@objManageTours.checkRecordCreated("Opportunity","SELECT id FROM Opportunity WHERE Account.name = '#{@leadsTestData[0]['company']}'")[0].fetch("Id")).to_not eql nil
        puts "opportunity created successfully"
        puts "\n"
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        puts "to check account allow merge"
        puts "\n"
        expect(ManageTours.class_variable_get(:@@recordInsertedIds)['Account'].fetch('Allow_Merge__c').eql? 'true').to be true
        puts "allow merge status is #{ManageTours.class_variable_get(:@@recordInsertedIds)['Account'].fetch('Allow_Merge__c')}\t\n"
        puts "to check total number of scheduled tours on contact"
        puts "\n"
        expect(ManageTours.class_variable_get(:@@recordInsertedIds)['Contact'].fetch('Total_Scheduled_Tours__c').to_i > 0).to be true
        puts "total number of scheduled tours => #{ManageTours.class_variable_get(:@@recordInsertedIds)['Contact'].fetch('Total_Scheduled_Tours__c')}\t\n"
        puts "to check tour is created"
        puts "\n"
        expect(@objManageTours.checkRecordCreated("Tour_Outcome__c","SELECT id,Status__c FROM Tour_Outcome__c WHERE Primary_Member__r.email = '#{@leadsTestData[0]['email']}'")[0].fetch("Id")).to_not eql nil
        puts "tour creataed successfully"
        puts "\n"
        puts "to check tour status"
        puts "\n"
        expect(ManageTours.class_variable_get(:@@recordInsertedIds)['Tour_Outcome__c'].fetch('Status__c').eql? "Scheduled").to be true
        puts "status checked successfully"
        puts "\n"
        puts "to check open activities"
        expect(@objManageTours.checkRecordCreated('Task',"SELECT id FROM Task WHERE whatId = '#{ManageTours.class_variable_get(:@@recordInsertedIds)['Tour_Outcome__c'].fetch('Id')}'")[0].fetch('Id')).to_not eql nil
        puts "to check that user can view booked tours information"
        puts "\n"
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        expect(@objManageTours.numberOfTourBooked == 3).to be true
        puts "C94 checked"
        puts "\n"
        @testRailUtility.postResult(94,"Result for case 94 is #{"success"}",1,@runId)
        @testRailUtility.postResult(362,"Result for case 94 is #{"success"}",1,@runId)
      rescue Exception => excp
        @testRailUtility.postResult(94,"Result for case 94 is #{excp}",5,@runId)
        @testRailUtility.postResult(362,"Result for case 94 is #{"success"}",5,@runId)
        raise excp
      end
    end
    it "C129 : to check user can cancel a tour"  , :test => true do
      puts "C129 : to check user can cancel a tour"
      puts "\n"
      begin
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        EnziUIUtility.selectElement(@driver,"Cancel","button")
        EnziUIUtility.selectChild(@driver,:id,"Cancellation_Reason__c","No reason (didn't provide)","option")
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        EnziUIUtility.selectElement(@driver,"Save","button")
        puts "to check user can cancel a tour"
        puts "\n"
        expect(@objManageTours.tourStatusChecked?("Cancelled" , @leadsTestData[0]['email'])).to be true
        puts "C129 checked"
        puts "\n"
        @testRailUtility.postResult(129,"Result for case 129 is #{"success"}",1,@runId)
      rescue Exception => excp
        @testRailUtility.postResult(129,"Result for case 129 is #{excp}",5,@runId)
        raise excp
      end
    end
    it "C102 : to check that tour is booked, when user clicks on 'Use Selector Account' button" , :test => true do
      puts "C102 : to check that tour is booked, when user clicks on 'Use Selector Account' button"
      puts "\n"
      begin
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        @leadsTestData[0]['email'] = "test_enzigmaPre#{rand(9999)}@example.com"
        @objManageTours.openPageForLead(Salesforce.createRecords(@objManageTours.instance_variable_get(:@salesforceBulk),'Lead',@leadsTestData)[0]['Id'])
        #@objManageTours.openPage(Salesforce.createRecords(@objManageTours.instance_variable_get(:@salesforceBulk),'Lead',@leadsTestData)[0]['Id'],:name,"lightning_manage_tours")
        Salesforce.addRecordsToDelete('Journey__c',@objManageTours.checkRecordCreated("Journey__c","SELECT id FROM Journey__c WHERE Primary_Email__c = '#{@leadsTestData[0]['email']}'")[0].fetch('Id'))
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        @objManageTours.bookTour(0,true)
        @objManageTours.duplicateAccountSelector("Use Selected Account","Yes")
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        puts "to check lead converted"
        puts "\n"
        expect(@objManageTours.checkRecordCreated("Lead","SELECT id,isConverted FROM Lead WHERE Email = '#{@leadsTestData[0]['email']}'")[0].fetch("IsConverted").eql? 'true').to be true
        puts "lead converted successfully"
        puts "\n"
        puts "to check contact created"
        puts "\n"
        expect(@objManageTours.checkRecordCreated("Contact","SELECT id,Account.name FROM Contact WHERE Email = '#{@leadsTestData[0]['email']}'")[0].fetch("Id")).to_not eql nil
        puts "contact created successfully"
        puts "\n"
        puts "to check tour is created"
        puts "\n"
        expect(@objManageTours.checkRecordCreated("Tour_Outcome__c","SELECT id,Status__c FROM Tour_Outcome__c WHERE Primary_Member__r.email = '#{@leadsTestData[0]['email']}'")[0].fetch("Id")).to_not eql nil
        puts "tour creataed successfully"
        puts "\n"
        puts "to check tour status"
        puts "\n"
        expect(ManageTours.class_variable_get(:@@recordInsertedIds)['Tour_Outcome__c'].fetch('Status__c').eql? "Scheduled").to be true
        puts "Tour outcome id ::"+ManageTours.class_variable_get(:@@recordInsertedIds)['Tour_Outcome__c'].fetch('Id')
        puts "status checked successfully"
        puts "\n"
        #sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        #if ManageTours.class_variable_get(:@@recordInsertedIds)['Account'].fetch('Number_Of_Open_Opportunities__c').eql? 0 then
        #expect(@objManageTours.checkRecordCreated("Opportunity","SELECT id FROM Opportunity WHERE Account.email = '#{@objManageTours.instance_variable_get(:@records)[2]['existingAccount']['email']}'")[0].fetch("Id")).to_not eql nil
        #else
        #expect(@objManageTours.checkRecordCreated("Opportunity","SELECT id FROM Opportunity WHERE Account.email = '#{@objManageTours.instance_variable_get(:@records)[2]['existingAccount']['email']}'")[0]).to eql nil
        #end
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        puts "to check open activities"
        expect(@objManageTours.checkRecordCreated('Task',"SELECT id FROM Task WHERE whatId = '#{ManageTours.class_variable_get(:@@recordInsertedIds)['Tour_Outcome__c'].fetch('Id')}'")[0].fetch('Id')).to_not eql nil
        puts "to check that user can view booked tours information"
        puts "\n"
        expect(@objManageTours.numberOfTourBooked == 3).to be true
        puts "C102 checked\n"
        @testRailUtility.postResult(102,"Result for case 102 is #{"success"}",1,@runId)
      rescue Exception => excp
        @testRailUtility.postResult(102,"Result for case 102 is #{excp}",5,@runId)
        raise excp
      end
    end
  end

  context "should check reschedule functionality" do
    it "C115 : to check that user can reschedule a tour" , :test => true do
      puts "C115 : to check that user can reschedule a tour"
      puts "\n"
      begin
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        @leadsTestData[0]['email'] = "test_enzigmaPre#{rand(9999)}@example.com"
        @leadsTestData[0]['company'] = "Test_Enzigma#{rand(1111)}"
        @objManageTours.openPageForLead(Salesforce.createRecords(@objManageTours.instance_variable_get(:@salesforceBulk),'Lead',@leadsTestData)[0]['Id'])
        #@objManageTours.openPage(Salesforce.createRecords(@objManageTours.instance_variable_get(:@salesforceBulk),'Lead',@leadsTestData)[0]['Id'],:name,"lightning_manage_tours")
        Salesforce.addRecordsToDelete('Journey__c',@objManageTours.checkRecordCreated("Journey__c","SELECT id FROM Journey__c WHERE Primary_Email__c = '#{@leadsTestData[0]['email']}'")[0].fetch('Id'))
        @objManageTours.bookTour(0,true)
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        @objManageTours.duplicateAccountSelector("Create Account and Don't Merge",nil)
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        puts "to check that user can reschedule a tour"
        puts "\n"
        @objManageTours.rescheduleTour
        expect(@objManageTours.tourStatusChecked?("Rescheduled" , @leadsTestData[0]['email'])).to be true
        puts "C115 checked"
        puts "\n"
        @testRailUtility.postResult(115,"Result for case 115 is #{"success"}",1,@runId)
      rescue Exception => excp
        @testRailUtility.postResult(115,"Result for case 115 is #{excp}",5,@runId)
        raise excp
      end
    end
  end
  context "check multiple tour booking" do
    it "C96 : to check that user can book multiple tour" do
      puts "C96 : to check that user can book multiple tour"
      puts "\n"
      begin
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
        puts "created tours =>  #{bookedTours.inspect}\t\n"
        expect(bookedTours.size > 1).to be true
        puts "\n"
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        puts "to check open activities"
        expect(@objManageTours.checkRecordCreated('Task',"SELECT id FROM Task WHERE whatId = '#{bookedTours[0].fetch('Id')}'")[0].fetch('Id')).to_not eql nil
        puts "to check that user can view booked tours information"
        puts "\n"
        expect(@objManageTours.numberOfTourBooked == 5).to be true
        puts "C96 checked"
        puts "\n"
        @testRailUtility.postResult(96,"Result for case 96 is #{"success"}",1,@runId)
      rescue Exception => excp
        @testRailUtility.postResult(96,"Result for case 96 is #{excp}",5,@runId)
        raise excp
      end
    end
  end
end
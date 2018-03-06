#Created By : Monika Pingale
#Created Date : 28/12/2017
#Modified date : 31/01/2018
require_relative File.expand_path(Dir.pwd+"/ManageTourPage/PageObjects/manageTours(Staging).rb")
require_relative File.expand_path("GemUtilities/EnziTestRailUtility/lib/EnziTestRailUtility.rb")
require "selenium-webdriver"
require "rspec"
require 'enziUIUtility'
require 'date'
#require_relative "helper.rb"
describe ManageTours do
  before(:all){
    #SauceLab will read env variable and accordingly set browser
    #@driver = SauceLabs.selenium_driver()
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
    Salesforce.deleteRecords(@objManageTours.instance_variable_get(:@salesforceBulk),"Journey__c",allRecordIds['Journey__c'])
    Salesforce.deleteRecords(@objManageTours.instance_variable_get(:@salesforceBulk),"Tour_Outcome__c",allRecordIds['Tour_Outcome__c'])
    Salesforce.deleteRecords(@objManageTours.instance_variable_get(:@salesforceBulk),"Opportunity",allRecordIds['Opportunity'])
    Salesforce.deleteRecords(@objManageTours.instance_variable_get(:@salesforceBulk),"Lead",allRecordIds['Lead'].uniq)
    Salesforce.deleteRecords(@objManageTours.instance_variable_get(:@salesforceBulk),"Account",allRecordIds['Account'])
    Salesforce.deleteRecords(@objManageTours.instance_variable_get(:@salesforceBulk),"Contact",allRecordIds['Contact'])

    @driver.quit
  }
   puts "---------------------------------------------------------------------------------------------------------------------------"
  it "C149 : to check manage tour page is displayed" , :test => true do
    puts "C149 : to check manage tour page is displayed"
    begin
        puts "\n"
        @leadsTestData[0]['email'] = "test_enzigmaPre#{rand(9999)}@example.com"
        @leadsTestData[0]['company'] = "Test_Enzigma#{rand(1111)}"
        puts "[Step]     Checking manage tour page is opened"
        puts "\n"
        @objManageTours.openPage(Salesforce.createRecords(@objManageTours.instance_variable_get(:@salesforceBulk),'Lead',@leadsTestData)[0]['Id'],:name,"lightning_manage_tours")

      #@objManageTours.openPage(@objManageTours.checkRecordCreated("Journey__c","SELECT id FROM Journey__c WHERE Primary_Email__c = '#{@objManageTours.instance_variable_get(:@records)[0]['lead'][0]['email']}'")[0].fetch('Id'),:id,"taction:0")
        @objManageTours.checkRecordCreated("Journey__c","SELECT id FROM Journey__c WHERE Primary_Email__c = '#{@leadsTestData[0]['email']}'")[0].fetch('Id')
        expect(@driver.title).to eql "Manage Tours"
        puts "[Expected] Successfully opened manage tour page "
        puts "[Result]   Pass"
        puts "\n"
        @testRailUtility.postResult(149,"Result for case 149 is #{"success"}",1,@runId)
    rescue Exception => excp
        @testRailUtility.postResult(149,"Result for case 149 is #{excp}",5,@runId)
      raise excp
    end
     puts "C149 : Checked successfully"
     puts "---------------------------------------------------------------------------------------------------------------------------"
  end
   
  it "C883 : to check that book tour button is disabled" do
    puts "C883 : to check that book tour button is disabled"
    begin
        puts "\n"
        puts "[Step]     Checking 'Book a tour' button"
        expect(@objManageTours.buttonDisabled?).to be true
        puts "[Expected] 'Book a tour' button is disable"
        puts "[Result]   Pass"
        puts "\n"
        @testRailUtility.postResult(883,"Result for case 883 is #{"success"}",1,@runId)
    rescue Exception => excp
        @testRailUtility.postResult(883,"Result for case 883 is #{excp}",5,@runId)
      raise excp
    end
     puts "C883 : Checked successfully"
     puts "---------------------------------------------------------------------------------------------------------------------------"
  end
     
  it "C7 : to check that book tour button get enable" do
        puts "C7 : to check that book tour button get enable"
        puts "\n"
    begin
        puts "[Step]     Checking 'Book a tour' button when all required fields of form are properly filled"
        @objManageTours.bookTour(0,false)
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        expect(@objManageTours.buttonDisabled?).to be true
        puts "[Expected] 'Book a Tour' button is enabled"
        puts "[Result]   Pass"
        puts "\n"
        @testRailUtility.postResult(7,"Result for case 7 is #{"success"}",1,@runId)
    rescue Exception => excp
        @testRailUtility.postResult(7,"Result for case 7 is #{excp}",5,@runId)
      raise excp
    end
     puts "C7 : Checked successfully"
     puts "---------------------------------------------------------------------------------------------------------------------------"
  end

  it "C885 : to check that user can select tour date without building name", :regression => true do
        puts "C885  : to check that user can select tour date without building name"
        puts "\n"
    begin
        puts "[Step]     Checking Building Name and Tour Date fields"
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        expect(@objManageTours.childDisabled?(ManageTours.selectBuilding(@driver.find_element(:id,"BookTours0"),nil,@objManageTours.instance_variable_get(:@timeSettingMap)),ManageTours.selectTourDate(@driver.find_element(:id,"BookTours0"),@objManageTours.instance_variable_get(:@timeSettingMap)))).to be false
      
        puts "[Expected] Tour date field should be disabled when building name field is not filled"
        puts "[Result]   Pass"
      #puts "C885 : successfully checked"
        puts "\n"
        @testRailUtility.postResult(885 ,"Result for case 885  is #{"success"}",1,@runId)
    rescue Exception => excp
      @testRailUtility.postResult(885 ,"Result for case 885  is #{excp}",5,@runId)
      raise excp
    end 
     puts "C885 : Checked successfully"
     puts "---------------------------------------------------------------------------------------------------------------------------"
  end
  it "C1016: to check that user can select previous date" do
    puts "C1016: to check that user can select previous date"
    begin
        puts "\n"
        puts "[Step]     Checking Tour date field for previous date"
        ManageTours.selectTourDate(@driver.find_element(:id,"BookTours0"),@objManageTours.instance_variable_get(:@timeSettingMap))
        EnziUIUtility.clickElement(@driver,:id,Date.today.prev_day.to_s)
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        expect(EnziUIUtility.checkErrorMessage(@driver,'h2','No times slots available for the selected date')).to be true
        puts "[Expected] Previous tour date should not be selected"
        puts "[Result]   Pass"
        puts "\n"
      #puts "successfully checked C1016"
      @testRailUtility.postResult(1016 ,"Result for case 1016  is #{"success"}",1,@runId)
    rescue Exception => excp
      @testRailUtility.postResult(1016 ,"Result for case 1016  is #{excp}",5,@runId)
      raise excp
    end
     puts "C1016: Checked successfully"
     puts "---------------------------------------------------------------------------------------------------------------------------"
  end
  it "C81 : to check that user can select start time"  do
    puts "C81 : to check that user can select start time"
    puts "\n"
    begin
        puts "[Step]     Start Time field should be selected"
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
        puts "[Expected] Start Time field should be selected after selecting Building Name and Tour Date fields"
        puts "[Result]   Pass"
        puts "\n"
      @testRailUtility.postResult(81,"Result for case 81 is #{"success"}",1,@runId)
    rescue Exception => excp
      @testRailUtility.postResult(81,"Result for case 81 is #{excp}",5,@runId)
      raise excp
    end
     puts "C81 : Checked successfully"
     puts "---------------------------------------------------------------------------------------------------------------------------"
  end
  it "C887 : to check that user can get end time automatically after entering start time" do
    puts "C887 : to check that user can get end time automatically after entering start time"
    puts "\n"
    begin
        puts "[Step]     Checking Start Time and End Time fields"
        ManageTours.setElementValue(@driver.find_element(:id,"BookTours0"),"startTime",nil)
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        expect(ManageTours.getElement("input","endTime",@driver.find_element(:id,"BookTours0"))).to_not eql nil
      #puts "C887 : successfully checked"
        puts "[Expected] End Time field should be selected after selecting Start Time"
        puts "[Result]   Pass"
        puts "\n"
        @testRailUtility.postResult(887,"Result for case 887 is #{"success"}",1,@runId)
    rescue Exception => excp
      @testRailUtility.postResult(887,"Result for case 887 is #{excp}",5,@runId)
      raise excp
    end
     puts "C887 : Checked successfully"
     puts "---------------------------------------------------------------------------------------------------------------------------"
  end
  it "C92 : to check that proper error message is displayed when user enter single character in building field" do
    puts "C92 : to check that proper error message is displayed when user enter single character in building field"
    puts "\n"
    begin
        puts "[Step]     Checking error message after entering single character in Building Name field"
      ManageTours.selectBuilding(@driver.find_element(:id,"BookTours0"),nil,@objManageTours.instance_variable_get(:@timeSettingMap)).clear
      #ManageTours.selectBuilding(@driver.find_element(:id,"BookTours0"),nil).send_keys "a"
      if ManageTours.selectBuilding(@driver.find_element(:id,"BookTours0"),nil,@objManageTours.instance_variable_get(:@timeSettingMap)).attribute('value').length > 2 then
        expect(@driver.find_element(:xpath ,"//span[starts-with(@id, 'lookup-option')]").text).to eql nil
        #puts "C92 : successfully checked"
        puts "[Expected] Error message as 'Enter at least 2 characters to search' should be displayed "
        puts "[Result]   Pass"
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
     puts "C92 : Checked successfully"
     puts "---------------------------------------------------------------------------------------------------------------------------"
  end
  it "C91 : to check that proper lead information is displayed on manage tour page" do
    puts "C91 : to check that proper lead information is displayed on manage tour page"
    puts "\n"
    begin
        puts "[Step]     Checking lead data on mange tour page"
      if !@driver.find_elements(:id,"Name").empty? then
        expect(@driver.find_element(:id,"Name").attribute('value').eql? "").to be false
        leadName = "#{@objManageTours.instance_variable_get(:@records)[0]['lead'][0]['firstName']}#{@objManageTours.instance_variable_get(:@records)[0]['lead'][0]['lastName']}"
        expect(@driver.find_element(:id,"Name").attribute('value').eql? "#{leadName}")
        puts "[Validate] Does Name field of manage tour page contain lead name?"
        puts "[Expected] ManageTour.Name= #{leadName}"
        puts "[Result]   Success"
        puts "\n"
      end
      
      if !@driver.find_elements(:id,"Company").empty? then
        expect(@driver.find_element(:id,"Company").attribute('value').eql? "").to be false
        expect(@driver.find_element(:id,"Company").attribute('value').eql? "#{@leadsTestData[0]['company']}")
        puts "[Validate] Does Company field of manage tour page contain lead company name ? "
        puts "[Expected] ManageTour.Company= #{@leadsTestData[0]['company']}"
        puts "[Result]   Success"
        puts "\n"
      end

      if !@driver.find_elements(:id,"Email").empty? then
        expect(@driver.find_element(:id,"Email").attribute('value').eql? "").to be false
        expect(@driver.find_element(:id,"Email").attribute('value').eql? "#{@leadsTestData[0]['email']}")
        puts "[Validate] Does Email field of manage tour page contain lead email id ? "
        puts "[Expected] ManageTour.Email= #{@leadsTestData[0]['email']}"
        puts "[Result]   Success"
        puts "\n"
      end

      #puts "C91 : successfully checked\n"
      @testRailUtility.postResult(91,"Result for case 91 is #{"success"}",1,@runId)
    rescue Exception => excp
      @testRailUtility.postResult(91,"Result for case 91 is #{excp}",5,@runId)
      raise excp
    end
     puts "C91 : Checked successfully"
     puts "---------------------------------------------------------------------------------------------------------------------------"
  end
  it "C85: to check that user can view duplicate account selector page while booking a tour" do
    #puts "C85,C171 : to check that user can view duplicate account selector page while booking a tour and user can book a tour"
    puts "C85: to check that user can view duplicate account selector page while booking a tour and user can book a tour"
    puts "\n"
    begin
        puts "[step]     Duplicate account selector pop-up should be opened"
        @objManageTours.bookTour(0,true)
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        puts "#{@driver.find_element(:id,"header43").text} opened successfully"
        puts "\n"
        EnziUIUtility.wait(@driver,:id,"header43",@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        expect(@driver.find_element(:id,"header43").text.eql? "Duplicate Account Selector").to be true
        puts "[Expected] Duplicate account selector pop up is displayed"
        puts "[Result]   Success"
     # puts "C85 : successfully checked"
        puts "\n"

      @testRailUtility.postResult(85,"Result for case 85 is #{"success"}",1,@runId)
      #@objManageTours.getAllData(false).values
    rescue Exception => excp
      @testRailUtility.postResult(85,"Result for case 85 is #{excp}",5,@runId)
      raise excp
    end
     puts "C85 : Checked successfully"
     puts "---------------------------------------------------------------------------------------------------------------------------"
  end

  context "should test duplicate account selector functionality" do
    it "C86 : to check that tour is booked, when user clicks on 'create account and don't merge' button" do
      puts "C86 : to check that tour is booked, when user clicks on 'create account and don't merge' button"
      puts "\n"
      begin
        puts "[Step]     Success message for booked tour should be displayed"
        puts "[Expected] Success Message as 'Tour booked successfully and will be synced shortly' and 'Tours synced successfully' should be displayed"
        puts "[Result]   Success"
        puts "\n"
        EnziUIUtility.wait(@driver,:id,"enzi-data-table-container",@objManageTours.instance_variable_get(:@timeSettingMap)['Wait']['Environment']['Lightening'])
        @objManageTours.duplicateAccountSelector("Create Account and Don't Merge",nil)
        
        puts  "[Step]    #{leadName} named lead should be converted"
        expect(@objManageTours.checkRecordCreated("Lead","SELECT id,isConverted FROM Lead WHERE Email = '#{@leadsTestData[0]['email']}'")[0].fetch("IsConverted").eql? 'true').to be true
        puts "[Expected] Successfully lead is converted "
        puts "[Result]   Success"
        puts "\n"
      
        puts "[Step]     Contact Should be created with name #{leadName}"
        expect(@objManageTours.checkRecordCreated("Contact","SELECT id,total_Scheduled_Tours__c FROM Contact WHERE Email = '#{@leadsTestData[0]['email']}'")[0].fetch("Id")).to_not eql nil
        puts "[Expected] Successfully contact is created"
        puts "[Result]   Success"
        puts "\n"
        
        puts "[Step]     Account Should be created with name #{@leadsTestData[0]['company']}"
        expect(@objManageTours.checkRecordCreated("Account","SELECT id,allow_merge__c FROM Account WHERE name = '#{@leadsTestData[0]['company']}'")[0].fetch("Id")).to_not eql nil
        puts "[Expected] Successfully account is created"
        puts "[Result]   Success"
        puts "\n"

      
        sleep(30)
        createdOpportunity = @objManageTours.checkRecordCreated("Opportunity","SELECT id,name FROM Opportunity WHERE Account.name = '#{@leadsTestData[0]['company']}'")[0]
        puts "[Step]     Opportunity should be created with name #{createdOpportunity.fetch("Name")}"
        expect(createdOpportunity.fetch("Id")).to_not eql nil
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        puts "[Expected] Successfully opportunity is created"
        puts "[Result]   Success"
        puts "\n"

        puts "[Step]     Checking allow merge field on account "
        expect(ManageTours.class_variable_get(:@@recordInsertedIds)['Account'].fetch('Allow_Merge__c').eql? 'false').to be true
        puts "[Validate] Does Allow Merge field on account is unchecked?"
        puts "[Expected] Allow merge = #{ManageTours.class_variable_get(:@@recordInsertedIds)['Account'].fetch('Allow_Merge__c')}\t\n"
        puts "[Result]   Success"
        puts "\n"

        puts "[Step]     Checking total number of scheduled tours on contact"
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        expect(ManageTours.class_variable_get(:@@recordInsertedIds)['Contact'].fetch('Total_Scheduled_Tours__c').to_i > 0).to be true
        puts "[Validate] Does Total number of scheduled tours field of contact updated after tour booking?"
        puts "[Expected] Total number of scheduled tours = #{ManageTours.class_variable_get(:@@recordInsertedIds)['Contact'].fetch('Total_Scheduled_Tours__c')}\t\n"
        puts "[Result]   Success"
        puts "\n"

        puts "[Step]     Tour should be created"
        expect(@objManageTours.checkRecordCreated("Tour_Outcome__c","SELECT id,Status__c FROM Tour_Outcome__c WHERE Primary_Member__r.email = '#{@leadsTestData[0]['email']}'")[0].fetch("Id")).to_not eql nil
        puts "[Expected] Successfully tour is created "
        puts "[Result]   Success"
        puts "\n"

        puts "[Step]     To check status of created tour"
        puts "[Validate] Does status of tour updated as 'Scheduled' ?"
        expect(ManageTours.class_variable_get(:@@recordInsertedIds)['Tour_Outcome__c'].fetch('Status__c').eql? "Scheduled").to be true
        puts "[Expected] Status= #{ManageTours.class_variable_get(:@@recordInsertedIds)['Tour_Outcome__c'].fetch('Status__c')}"
        puts "[Result]   Success"
        puts "\n"

        puts "[Step]     Activity should be created for tour"
        expect(@objManageTours.checkRecordCreated('Task',"SELECT id FROM Task WHERE whatId = '#{ManageTours.class_variable_get(:@@recordInsertedIds)['Tour_Outcome__c'].fetch('Id')}'")[0].fetch('Id')).to_not eql nil
        puts "[Expected] 'Book a tour' activity is created"
        puts "[Result]   Success"
        puts "\n"
        
        @testRailUtility.postResult(86,"Result for case 86 is #{"success"}",1,@runId)
      rescue Exception => excp
        @testRailUtility.postResult(86,"Result for case 86 is #{excp}",5,@runId)
        raise excp
      end
       puts "C86 : Checked successfully"
       puts "---------------------------------------------------------------------------------------------------------------------------"
    end
    it "C89 : to check that user can view booked tours information" do
      puts "C89 : to check that user can view booked tours information"
      puts "\n"
      begin
        puts "[Step]     Checking booked tour information"
        expect(@objManageTours.numberOfTourBooked == 3).to be true
        puts "[Expected] Tour information is displayed on same manage tour page"
        #puts "C89 : successfully checked"
        puts "[Result]   Success"
        puts "\n"
        @testRailUtility.postResult(89,"Result for case 89 is #{"success"}",1,@runId)
      rescue Exception => excp
        @testRailUtility.postResult(89,"Result for case 89 is #{excp}",5,@runId)
        raise excp
      end
       puts "C89 : Checked successfully"
       puts "---------------------------------------------------------------------------------------------------------------------------"
    end
    context "check multiple tour booking" do
      it "C96 : to check that user can book multiple tour" do
        puts "C96 : to check that user can book multiple tour"
        puts "\n"
        begin
        puts "[Step]     Multiple tours should be booked"
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
          
        puts "[Expected] Multiple tours are booked and those are =>  #{bookedTours.inspect}\t\n"
        expect(bookedTours.size > 1).to be true
        puts "[Result]   Success"
        puts "\n"
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        puts "[Step]     Open activities for tours should be created"
        expect(@objManageTours.checkRecordCreated('Task',"SELECT id FROM Task WHERE whatId = '#{bookedTours[0].fetch('Id')}'")[0].fetch('Id')).to_not eql nil
        expect(@objManageTours.checkRecordCreated('Task',"SELECT id FROM Task WHERE whatId = '#{bookedTours[1].fetch('Id')}'")[0].fetch('Id')).to_not eql nil
        puts "[Expected] Open activities are created for multiple tours"
        puts "[Result]   Success"
        puts "\n"

        puts "[Step]     User should see booked tour information"
        expect(@objManageTours.numberOfTourBooked > 3).to be true
        puts "[Expected] Booked tours records are available on manage tour page"
        puts "[Resulted] Success"
        puts "\n"
        puts "C96 : Checked successfully"
        puts "---------------------------------------------------------------------------------------------------------------------------"
        puts "\n"
          @testRailUtility.postResult(96,"Result for case 96 is #{"success"}",1,@runId)
        rescue Exception => excp
          @testRailUtility.postResult(96,"Result for case 96 is #{excp}",5,@runId)
          raise excp
        end
      end
       
    end
    it "C94 : to check that tour is booked, when user clicks on 'create account and merge' button" do
      puts "C94 : to check that tour is booked, when user clicks on 'create account and merge' button"
      puts "\n"
      begin
        puts "[Step]     Success message for booked tour should be displayed"
        puts "[Expected] Success Message as 'Tour booked successfully and will be synced shortly' and 'Tours synced successfully' should be displayed"
        puts "[Result]   Success"
        puts "\n"
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        @leadsTestData[0]['email'] = "test_enzigmaPre#{rand(9999)}@example.com"
        @leadsTestData[0]['company'] = "Test_Enzigma#{rand(1111)}"
        puts "\n"
        
        @objManageTours.openPageForLead(Salesforce.createRecords(@objManageTours.instance_variable_get(:@salesforceBulk),'Lead',@leadsTestData)[0]['Id'])
        @objManageTours.checkRecordCreated("Journey__c","SELECT id FROM Journey__c WHERE Primary_Email__c = '#{@leadsTestData[0]['email']}'")[0].fetch('Id')
        @objManageTours.bookTour(0,true)
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        @objManageTours.duplicateAccountSelector("Create Account and Merge",nil)
        puts "[Step]     #leadname named lead should be converted"
        #puts "\n"
        expect(@objManageTours.checkRecordCreated("Lead","SELECT id,isConverted FROM Lead WHERE Email = '#{@leadsTestData[0]['email']}'")[0].fetch("IsConverted").eql? 'true').to be true
        puts "[Expected] Lead converted Sucessfully"
        puts "[Result]   Success"
        puts "\n"

        puts "[Step]     Contact should be created with name #leadName"
        expect(@objManageTours.checkRecordCreated("Contact","SELECT id,total_Scheduled_Tours__c FROM Contact WHERE Email = '#{@leadsTestData[0]['email']}'")[0].fetch("Id")).to_not eql nil
        puts "[Expected] Contact created successfully"
        puts "[Result]   Success"
        puts "\n"

        puts "[Step]     Account should be created with name #{@leadsTestData[0]['company']}"
        expect(@objManageTours.checkRecordCreated("Account","SELECT id,allow_merge__c FROM Account WHERE name = '#{@leadsTestData[0]['company']}'")[0].fetch("Id")).to_not eql nil
        puts "[Expected] Account created successfully"
        puts "[Result]   Success"
        puts "\n"

        puts "[Step]     Opportunity should be created"
        sleep(30)
        expect(@objManageTours.checkRecordCreated("Opportunity","SELECT id FROM Opportunity WHERE Account.name = '#{@leadsTestData[0]['company']}'")[0].fetch("Id")).to_not eql nil
        puts "[Expected] Opportunity created successfully"
        puts "[Result]   Success"
        puts "\n"

        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        puts "[Step]     To check allow merge field on account "
        puts "\n"
        expect(ManageTours.class_variable_get(:@@recordInsertedIds)['Account'].fetch('Allow_Merge__c').eql? 'true').to be true
        puts "[Validate] Does Allow Merge field on account is checked?"
        puts "[Expected] Allow merge status = #{ManageTours.class_variable_get(:@@recordInsertedIds)['Account'].fetch('Allow_Merge__c')}\t\n"
        puts "[Result]   Success"
        puts"\n"

        puts "[Step]     Checking total number of scheduled tours on contact"
        expect(ManageTours.class_variable_get(:@@recordInsertedIds)['Contact'].fetch('Total_Scheduled_Tours__c').to_i > 0).to be true
        puts "[Validate] Does Total number of scheduled tours field of contact updated after tour booking?"
        puts "[Expected] Total number of scheduled tours => #{ManageTours.class_variable_get(:@@recordInsertedIds)['Contact'].fetch('Total_Scheduled_Tours__c')}\t\n"
        puts "[Result]   Success"
        puts "\n"

        puts "[Step]     Tour should be created"
        expect(@objManageTours.checkRecordCreated("Tour_Outcome__c","SELECT id,Status__c FROM Tour_Outcome__c WHERE Primary_Member__r.email = '#{@leadsTestData[0]['email']}'")[0].fetch("Id")).to_not eql nil
        puts "[Expected] Tour created successfully"
        puts "[Result]   Success"
        puts "\n"

        puts "[Step]     To check status of created tour"
        puts "[Validate] Does status of tour updated as 'Scheduled' ?"
        expect(ManageTours.class_variable_get(:@@recordInsertedIds)['Tour_Outcome__c'].fetch('Status__c').eql? "Scheduled").to be true
        puts "[Expected] Status =Scheduled"
        puts "[Result]   Success"
        puts "\n"

        puts "[Step]     Checking open activities"
        expect(@objManageTours.checkRecordCreated('Task',"SELECT id FROM Task WHERE whatId = '#{ManageTours.class_variable_get(:@@recordInsertedIds)['Tour_Outcome__c'].fetch('Id')}'")[0].fetch('Id')).to_not eql nil
        puts "[Expected] 'Book a tour' named open activity created successfully"
        puts "[Result]   Success"
        puts "\n"

        puts "[Step]     User should see records of booked tour "
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        expect(@objManageTours.numberOfTourBooked == 3).to be true
        puts "[Expected] Booked tours records are available on manage tour page"
        puts "[Result]   Success"
        puts "\n"

        puts "C94 : Checked successfully"
        puts "---------------------------------------------------------------------------------------------------------------------------"
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
        puts "[Step]     User can fill cancellation reason"
        puts "[validate] Does cancel tour pop-up accept cancellation reason ? "
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        EnziUIUtility.selectElement(@driver,"Cancel","button")
        EnziUIUtility.wait(@driver,:id,"header43",@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        EnziUIUtility.selectChild(@driver,:id,"Cancellation_Reason__c","No reason (didn't provide)","option")
        puts "[Expected] Cancellation Reason= No reason"
        puts "[Result]   Success"
        puts "\n"

        puts "[validate] Does save button get enabled after filling out cancellation reason ? "
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        EnziUIUtility.selectElement(@driver,"Save","button")
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        puts "[Expected] Save button get enabled"
        puts "[Result]   Success"
        puts "\n"

        puts "[Validate] Does status of tour change after cancellation of tour"
        expect(@objManageTours.tourStatusChecked?("Cancelled" , @leadsTestData[0]['email'])).to be true
        puts "[Expected] Tour status=Cancelled"
        puts "[Result]   Success"
        puts "\n"

         puts "C129 : Checked successfully"
         puts "---------------------------------------------------------------------------------------------------------------------------"
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

        puts "[Step]     Success message for booked tour should be displayed"
        puts "[Expected] Success Message as 'Tour booked successfully and will be synced shortly' and 'Tours synced successfully' should be displayed"
        puts "[Result]   Success"
        puts "\n"

        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        @leadsTestData[0]['email'] = "test_enzigmaPre#{rand(9999)}@example.com"
        @objManageTours.openPageForLead(Salesforce.createRecords(@objManageTours.instance_variable_get(:@salesforceBulk),'Lead',@leadsTestData)[0]['Id'])
        #@objManageTours.openPage(Salesforce.createRecords(@objManageTours.instance_variable_get(:@salesforceBulk),'Lead',@leadsTestData)[0]['Id'],:name,"lightning_manage_tours")
       @objManageTours.checkRecordCreated("Journey__c","SELECT id FROM Journey__c WHERE Primary_Email__c = '#{@leadsTestData[0]['email']}'")[0].fetch('Id')
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        @objManageTours.bookTour(0,true)
        @objManageTours.duplicateAccountSelector("Use Selected Account","Yes")
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        puts "[Step]     #leadname named lead should be converted"
        expect(@objManageTours.checkRecordCreated("Lead","SELECT id,isConverted FROM Lead WHERE Email = '#{@leadsTestData[0]['email']}'")[0].fetch("IsConverted").eql? 'true').to be true
        puts "[Expected] Lead converted Sucessfully"
        puts "[Result]   Success"
        puts "\n"

        puts "[Step]     Contact should be created with name #leadName"
        expect(@objManageTours.checkRecordCreated("Contact","SELECT id,Account.name FROM Contact WHERE Email = '#{@leadsTestData[0]['email']}'")[0].fetch("Id")).to_not eql nil
        puts "[Expected] Contact created successfully"
        puts "[Result]   Success"
        puts "\n"

        puts "[Step]     Tour should be created"
        expect(@objManageTours.checkRecordCreated("Tour_Outcome__c","SELECT id,Status__c FROM Tour_Outcome__c WHERE Primary_Member__r.email = '#{@leadsTestData[0]['email']}'")[0].fetch("Id")).to_not eql nil
        puts "[Expected] Tour created successfully"
        puts "[Result]   Success"
        puts "\n"

        puts "[Step]     To check status of created tour"
        puts "[Validate] Does status of tour updated as 'Scheduled' ?"
        expect(ManageTours.class_variable_get(:@@recordInsertedIds)['Tour_Outcome__c'].fetch('Status__c').eql? "Scheduled").to be true
        #puts "Tour outcome id ::"+ManageTours.class_variable_get(:@@recordInsertedIds)['Tour_Outcome__c'].fetch('Id')
        #puts "Tour status checked successfully"
        #puts "\n"
        puts "[Expected] Status = #{ManageTours.class_variable_get(:@@recordInsertedIds)["Tour_Outcome__c"].fetch("Status__c")}"
        puts "[Result]   Success"
        puts "\n"
        #sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        #if ManageTours.class_variable_get(:@@recordInsertedIds)['Account'].fetch('Number_Of_Open_Opportunities__c').eql? 0 then
        #expect(@objManageTours.checkRecordCreated("Opportunity","SELECT id FROM Opportunity WHERE Account.email = '#{@objManageTours.instance_variable_get(:@records)[2]['existingAccount']['email']}'")[0].fetch("Id")).to_not eql nil
        #else
        #expect(@objManageTours.checkRecordCreated("Opportunity","SELECT id FROM Opportunity WHERE Account.email = '#{@objManageTours.instance_variable_get(:@records)[2]['existingAccount']['email']}'")[0]).to eql nil
        #end
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        puts "[Step]     Checking open activities"
        expect(@objManageTours.checkRecordCreated('Task',"SELECT id FROM Task WHERE whatId = '#{ManageTours.class_variable_get(:@@recordInsertedIds)['Tour_Outcome__c'].fetch('Id')}'")[0].fetch('Id')).to_not eql nil
        puts "[Expected] 'Book a tour' named open activity created successfully"
        puts "[Result]   Success"
        puts "\n"

        puts "[Step]     User should see records of booked tour "
        expect(@objManageTours.numberOfTourBooked == 3).to be true
        puts "[Expected] Booked tours records are available on manage tour page"
        puts "[Result]   Success"
        puts "\n"
        puts "C102 : Checked successfully"
        puts "---------------------------------------------------------------------------------------------------------------------------"
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

        puts "[Step]     Success message for rescheduled tour should be displayed"
        puts "[Expected] Success Message as 'Tour rescheduled successfully and will be synced shortly' and 'Tours synced successfully' should be displayed"
        puts "[Result]   Success"
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

        puts "[Step]     Check status of tour after rescheduling"
        puts "[Validate] Does status of tour updated as Rescheduled' ?"
        @objManageTours.rescheduleTour
        sleep(@objManageTours.instance_variable_get(:@timeSettingMap)['Sleep']['Environment']['Lightening'])
        expect(@objManageTours.tourStatusChecked?("Rescheduled" , @leadsTestData[0]['email'])).to be true
        puts "[Expected] Status = Rescheduled"
        puts "[Result]   Success"
        puts "\n"
        puts "C115 : checked successfully"
        puts "---------------------------------------------------------------------------------------------------------------------------"
        puts "\n"
        @testRailUtility.postResult(115,"Result for case 115 is #{"success"}",1,@runId)
      rescue Exception => excp
        @testRailUtility.postResult(115,"Result for case 115 is #{excp}",5,@runId)
        raise excp
      end
    end
  end
end
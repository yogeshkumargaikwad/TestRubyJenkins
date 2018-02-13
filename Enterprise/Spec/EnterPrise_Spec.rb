#Created By   : Pragalbha Mahajan
#Created Date : 22/01/2018
#Modified date:

require_relative '../Utility/EnziUIUtility/lib/enziUIUtility.rb'
require 'salesforce'
require 'selenium-webdriver'
require 'yaml'
require 'json'
require "rspec"
require 'saucelabs'
#require_relative '../Utility/httparty/SfRESTService'
#require_relative 'E:/Projects/Training/Enterprise/PageObject/EnterPrise.rb'
#require_relative '../TestData/Credentials'
require_relative '../PageObject/EnterPrise'
require_relative '../Utility/EnziTestRailUtility/lib/EnziTestRailUtility'

describe "Enterprise" do
  RSpec.shared_examples "test" do |index|

    it 'Login by user' do
      EnziUIUtility.wait(@driver,:id,'phSearchInput',25)
      @objEnterPrise.loginForUser(@testRecords['profile'][index])
      EnziUIUtility.wait(@driver,nil, nil,5)
      EnziUIUtility.switchToWindow(@driver,"Home | Salesforce")
      puts "Successfully Logged In by #{@testRecords['profile'][index]} Profile"
    end

    it 'C867: To check "New Organization" button is enabled when create opportunity is accessed from global action.' do
      #begin
      @objEnterPrise.navigateToCreateOpportunity()
      EnziUIUtility.wait(@driver,:id,'Budget_Monthly__c',40)
      @objEnterPrise.selectElement(@driver,"Maximize","button")
      expect(@objEnterPrise.buttonEnabled?("GlobalActionManager:New_Organization")).to eq true
      puts "New Organization button is enabled in create Opportunity with Global Action"
      #@objEnterPrise.selectElement(@driver,"Close","button")

      #@testRailUtility.postResult(867,"comment",1,@run["id"])
      #rescue
      #@testRailUtility.postResult(867,"comment",5,@run["id"])
      #end
    end

    it 'C868: To check new account is created through "New Organization".' do
      begin
      @objEnterPrise.createNewOrganization(@testRecords['account'][0], "5")
      #@objEnterPrise.selectElement(@driver,"Close","button")
      expect(@@accountId = @objEnterPrise.getAccountFields(@testRecords['account'][0]).fetch("Id")).should_not be_nil
      puts "New Organization is Created"
      @testRailUtility.postResult(868,"comment",1,@run["id"])
      rescue Exception => e
        @testRailUtility.postResult(868,e,5,@run["id"])
        raise e
      end
    end

    it 'C869: To check duplicate account creation.' do
      begin
      #@objEnterPrise.selectElement(@driver,"Close","button")
      @driver.navigate.refresh
      @objEnterPrise.navigateToCreateOpportunity()
      EnziUIUtility.wait(@driver,:id,'Budget_Monthly__c',20)
      @objEnterPrise.selectElement(@driver,"Maximize","button")
      @objEnterPrise.createNewOrganization(@testRecords['account'][0], "5")
      expect(@objEnterPrise.checkError("div","You can't create duplicate Organization.")).to eq true
      puts "Duplicate Organization cannot be created"
      Salesforce.addRecordsToDelete("Account", "#{@@accountId}")
      @testRailUtility.postResult(869,"comment",1,@run["id"])
      rescue Exception => e
        @testRailUtility.postResult(869,e,5,@run["id"])
        raise e
      end
    end

    it 'C870: To check opportunity is created with stage "Qualifying"' do
        begin
        recordId = @objEnterPrise.createOpportunity("Primary Member", "Amit Kasar NMD", "CHI-National Building", "Enzigma Enterprise 01", nil, "2", "100")
        #recordId = @objEnterPrise.createOpportunity()
        puts "recordId: #{recordId}"
        expect(@objEnterPrise.getOpportunityFields(recordId).fetch("StageName")).to eq "Qualifying"
        expect(@objEnterPrise.getOpportunityFields(recordId).fetch("Stage_Details__c")).to eq "Qualify Opportunity"
        puts "Opportunity is created with stage as Qualifying and stage detail as Qualify Opportunity"
        Salesforce.addRecordsToDelete("Opportunity", "#{recordId}")
        @testRailUtility.postResult(870,"comment",1,@run["id"])
        rescue Exception => e
          @testRailUtility.postResult(870,e,5,@run["id"])
          raise e
        end
    end


    it 'C873: To check opportunity is created with stage "Selling".' do
      begin
      #@driver.navigate.refresh
      #@objEnterPrise.navigateToCreateOpportunity()
      recordId = @objEnterPrise.createOpportunity("Decision Maker", "Amit Kasar NMD", "CHI-National Building", "Enzigma Enterprise 01", nil, "2", "100", nil, nil, "2018-2-23", nil, "2", nil)
=begin
      EnziUIUtility.wait(@driver,:id,"Budget_Monthly__c",20)
      @objEnterPrise.selectElement(@driver,"Maximize","button")
      EnziUIUtility.wait(@driver,:id,"Budget_Monthly__c",20)
      EnziUIUtility.setValue(@driver,:id,"Budget_Monthly__c",100)
      EnziUIUtility.setValue(@driver,:id,"Interested_in_Number_of_Desks__c",2)
      EnziUIUtility.selectOption(@driver,:id,"Role__c","Decision Maker")

      EnziUIUtility.setValue(@driver,:id,"OppRoleContact","Amit Kasar NMD")
      EnziUIUtility.wait(@driver,nil,nil,6)
      @driver.find_element(:id,'OppRoleContactlist').find_elements(:tag_name,"li").each do |list|
        if list.attribute('title') == "Amit Kasar NMD"
          #puts "list title: #{list.attribute('title')}"
          wait = Selenium::WebDriver::Wait.new(:timeout => 20);
          #sleep(20)
          wait.until {list.displayed?}
          list.click
        end
      end
      @driver.execute_script("arguments[0].scrollIntoView();" , @driver.find_element(:id ,"Term__c"))
      EnziUIUtility.setValue(@driver,:id,"Term__c",2)
      EnziUIUtility.setValue(@driver,:id,"Building","CHI-National Building")
      EnziUIUtility.wait(@driver,nil,nil,6)
      @driver.find_element(:id,'Buildinglist').find_elements(:tag_name,"li").each do |list|
        if list.attribute('title') == "CHI-National Building"
          #puts "list title: #{list.attribute('title')}"
          wait = Selenium::WebDriver::Wait.new(:timeout => 20);
          #sleep(20)
          wait.until {list.displayed?}
          list.click
        end
      end
      EnziUIUtility.wait(@driver,:id,'Move_In_Date__c',15)
      @driver.find_element(:id,'Move_In_Date__c').click
      @driver.execute_script("arguments[0].scrollIntoView();" , @driver.find_element(:link ,"Today"))
      EnziUIUtility.clickElement(@driver, :link, "Today")
      sleep(10)
      #@objEnterPrise.setMoveInDate("2019-2-23")
      @objEnterPrise.selectElement(@driver,"Save & Close","button")

      sleep(10)
      urlArr = @driver.current_url.split('/')
      #puts "urlArr: #{urlArr}"
      #puts "urlArr[6]: #{urlArr[6]}"
      oppId = urlArr[6]
      @@oppIdForTeamMember = oppId
=end
      puts "recordId: #{recordId}"
      expect(@objEnterPrise.getOpportunityFields(recordId).fetch("StageName")).to eq "Selling"
      expect(@objEnterPrise.getOpportunityFields(recordId).fetch("Stage_Details__c")).to eq "Sales Rep Searching Space"
      puts "Opportunity Created with Stage as Selling and Stage Details as Sales Rep Searching Space"
      Salesforce.addRecordsToDelete("Opportunity", "#{recordId}")
      #sleep(120)

      @testRailUtility.postResult(873,"comment",1,@run["id"])
      rescue Exception => e
        @testRailUtility.postResult(873,"comment",5,@run["id"])
        raise e
      end
    end


=begin
    it 'C875: To check opportunity member is created when opportunity is created' do
      expect(@objEnterPrise.getOpportunityTeamMemberFields(@@oppIdForTeamMember).fetch("Name")).to eq "Hemans"
    end
=end

=begin
    it 'C871: To check "New Organization" button is disabled when create opportunity is accessed from account.' do
      #begin
      @driver.navigate.refresh
      EnziUIUtility.wait(@driver,nil,nil,10)
      @objEnterPrise.navigateToAccountDetails("Accounts")
      #EnziUIUtility.wait(@driver,nil,nil,30)
      sleep(30)
      EnziUIUtility.wait(@driver,:class,'sldsButtonHeightFix',30)
      @driver.find_element(:class,'sldsButtonHeightFix').click
      sleep(2)  #changed on 6 feb
      #@driver.find_element(:class,'sldsButtonHeightFix').click  #changed on 6 feb
      #@objEnterPrise.selectElement(@driver,"Show more actions","a")
      @driver.find_element(:link, 'Create Opportunity').click
      EnziUIUtility.wait(@driver,nil,nil,20)
      expect(@objEnterPrise.buttonEnabled?("GlobalActionManager:New_Organization")).to eq false
      @objEnterPrise.selectElement(@driver,"Close this window","button")

      #@testRailUtility.postResult(871,"comment",1,@run["id"])
      #rescue
        #@testRailUtility.postResult(871,"comment",5,@run["id"])
      #end
    end
=end

    it "Record Deletion" do
      @objEnterPrise.delRecord("Account")
      @objEnterPrise.delRecord("Opportunity")
    end

    it 'logout from current user' do
      @objEnterPrise.logOut()
    end
  end

  before(:all){
    puts "in all"
    include SauceLabs
    #SauceLab will read env variable and accordingly set browser
    @driver = SauceLabs.selenium_driver()
    #@driver = Selenium::WebDriver.for :chrome
    @objEnterPrise = EnterPrise.new(@driver)
    testRecordFile = File.open("Enterprise/TestData/UserSettings.json", "r")
    testRecordsInJson = testRecordFile.read()
    @testRecords = JSON.parse(testRecordsInJson)
    #@@oppIdForTeamMember = nil

    config = YAML.load_file('credentials.yaml')
    @testRailUtility = EnziTestRailUtility::TestRailUtility.new(config['TestRail']['username'],config['TestRail']['password'])
    @run = @testRailUtility.addRun("EnterPriseRun",4,@testRailUtility.getSuitByName(4,"Enterprise"))
    puts "cg : #{@testRailUtility}"
  }

  context  'Navigaton to Manage Users' do
    it "should go to Home page", :sanity => true do
      if expect(@objEnterPrise.getDriver.title).to eq "Salesforce - Unlimited Edition"
        puts "Successfully redirected to Home Page"
      end
    end

    it "should go to Manage Users Page", :sanity => true do
      @objEnterPrise.redirectToUsers()
      puts "Successfully redirected to Manage Users Page"
    end

    it "should select view as EnterPrise Demo Users", :sanity => true do
      EnziUIUtility.selectOption(@driver,:id,"fcf","Enterprise Demo Users")
      #EnziUIUtility.wait(@driver,nil,nil,10)
      puts "Successfully selected Enterprise Demo Users"      #c1 s2 r d s r3
    end
  end

  context 'Navigation to Create opportunity with global action' do
    index = 1
     loop do
      include_examples "test", index
      #puts "world"
      index = index + 1
      if index == 6
        break
      end
    end
  end
end

=begin

	context 'Login With Different Users' do
		it "Login With " do
			@objEnterPrise.loginForUser(@testRecords['profile'][1])
			#@driver.navigate().back();
		end
	end

	context 'Navigation to Create opportunity with Account' do
		it 'Check for button Enability of New Organization with Account' do
			@objEnterPrise.navigateToAccountDetails("Accounts")
			@objEnterPrise.createOpportunityFromAccounts()
					#@objEnterPrise.createOpportunityFromAccounts()
					drpdwn = @driver.find_element(:class,'oneActionsDropDown')
					puts "drpdwn: #{drpdwn}"
					puts "drpdwn first div class: #{drpdwn.find_elements(:tag_name,"div")[0].attribute('class')}"
					anchorRedirect = drpdwn.find_elements(:tag_name,"div")[0].find_elements(:tag_name,"div")[0].find_elements(:tag_name,"div")[0].find_elements(:tag_name,"div")[0]
					puts "anchorRedirect: #{anchorRedirect}"
					puts "anchorRedirect class: #{anchorRedirect.find_element(:tag_name,'a').attribute('class')}"
					anchorElement = anchorRedirect.find_element(:tag_name,'a')
					puts "anchorElement: #{anchorElement}"
					puts "#{anchorElement.attribute('role')}"
					anchorElement.click
					#puts anchorElement.find_element(:tag_name,'svg')
					#anchorElement.find_element(:tag_name,'svg').click
					#EnziUIUtility.wait(@driver,nil,nil,5)
					#@driver.find_element(:link, 'Show more actions').click
					#EnziUIUtility.wait(@driver,nil,nil,5)
					#spans = anchorElement.find_elements(:tag_name,'span')
					#spans[0].click
					#sleep(5)
					#spans[1].click
					#spans[2].click
					#anchorElement.find_elements(:tag_name,'span')[1].click
					#anchorElement.find_elements(:tag_name,'span')[2].click
					#puts "Spans: #{spans}"
					#@driver.find_element(:link, 'Create Opportunity').click
					#@objEnterPrise.selectElement(@driver,"Show more actions","a")
					#@objEnterPrise.selectElement(@driver,"Create Opportunity","a")
		end
	end

	context 'Navigation to Create opportunity with Contact' do
		it 'Check for button Enability of New Organization with Contact' do
			@objEnterPrise.navigateToAccountDetails("Contacts")
			@objEnterPrise.createOpportunityFromAccounts()
		end
	end

	context 'Logout from user' do
		it "Logout for current User" do
			@objEnterPrise.logOut()
		end
	end
=end
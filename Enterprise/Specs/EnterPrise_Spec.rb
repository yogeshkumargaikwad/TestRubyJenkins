#Created By   : Pragalbha Mahajan
#Created Date : 22/01/2018
#Modified date:

require 'salesforce'
require 'selenium-webdriver'
require 'yaml'
require 'json'
require "rspec"
#require 'saucelabs'

#require_relative '../Utility/EnziUIUtility/lib/enziUIUtility.rb'
#require_relative '/Enterprise/Utilities/httparty/SfRESTService'
#require_relative 'E:/Projects/Training/Enterprise/PageObject/EnterPrise.rb'
#require_relative '../TestData/Credentials'
#require_relative '../Spec/helper'

require_relative File.expand_path(Dir.pwd + '/Enterprise/Utilities/EnziUIUtility/lib/enziUIUtility.rb')
require_relative File.expand_path(Dir.pwd + '/Enterprise/PageObjects/EnterPrise.rb')
require_relative File.expand_path(Dir.pwd + '/Enterprise/Utilities/EnziTestRailUtility/lib/EnziTestRailUtility.rb')
require_relative File.expand_path(Dir.pwd + '/Enterprise/Utilities/httparty/SfRESTService.rb')
require_relative File.expand_path(Dir.pwd + '/GemUtilities/RollbarUtility/rollbarUtility.rb')
#require_relative File.expand_path("..", Dir.pwd) + '/Enterprise/Utilities/EnziTestRailUtility/lib/EnziTestRailUtility.rb'
#require_relative '../PageObject/EnterPrise'
#require_relative '../Utility/EnziTestRailUtility/lib/EnziTestRailUtility'
#require_relative '../Utility/httparty/SfRESTService.rb'

describe "Enterprise" do
  RSpec.shared_examples "test" do |index|

    context "Create Opportunity with global Action" do
      before(:example) {
        puts ""
        puts "-----------------------------------------------------------------------------------------------"
      }
      it 'Login by user' do
        EnziUIUtility.wait(@driver, :id, 'phSearchInput', @timeSetting['Wait']['Environment']['Classic']['Min'])
        @objEnterPrise.loginForUser(@testRecords['profile'][index])
        #EnziUIUtility.wait(@driver, nil, nil, @timeSetting['Sleep']['Environment']['Classic'])
        EnziUIUtility.switchToWindow(@driver, "Home | Salesforce")
        puts "Successfully Logged In by #{@testRecords['profile'][index]} Profile"
      end

      it 'C1012: To check "New Organization" button is enable on create opportunity page' do
        begin
          @objEnterPrise.navigateToCreateOpportunity()
          EnziUIUtility.wait(@driver, :id, 'Budget_Monthly__c', @timeSetting['Wait']['Environment']['Lightening']['Min'])
          @objEnterPrise.selectElement(@driver, "Maximize", "button")
          expect(@objEnterPrise.buttonEnabled?("GlobalActionManager:New_Organization")).to eq true
          puts "New Organization button is enabled in create Opportunity with Global Action"
          #@objEnterPrise.selectElement(@driver,"Close","button")

          @testRailUtility.postResult(1012, "comment", 1, @run)
        rescue Exception => e
          Rollbar.error(e)
          @testRailUtility.postResult(1012, e, 5, @run)
          puts e
          raise e
        end
      end

      it 'C868: To check new account is created through "New Organization".' do
        begin
          @objEnterPrise.createNewOrganization(@testRecords['account'][0], "5")
          #@objEnterPrise.selectElement(@driver,"Close","button")
          expect(accountId = @objEnterPrise.getAccountFields(@testRecords['account'][0]).fetch("Id")).should_not nil
          puts "New Organization is successfully created"
          Salesforce.addRecordsToDelete("Account", "#{accountId}")

          @testRailUtility.postResult(868, "comment", 1, @run)
        rescue Exception => e
          Rollbar.error(e)
          @testRailUtility.postResult(868, e, 5, @run)
          puts e
          raise e
        end
      end

      it 'C869: To check duplicate account creation.' do
        begin
          #@objEnterPrise.selectElement(@driver,"Close","button")
          @driver.navigate.refresh
          @objEnterPrise.navigateToCreateOpportunity()
          EnziUIUtility.wait(@driver, :id, 'Budget_Monthly__c', @timeSetting['Wait']['Environment']['Lightening']['Min'])
          @objEnterPrise.selectElement(@driver, "Maximize", "button")
          @objEnterPrise.createNewOrganization(@testRecords['account'][0], "5")
          expect(@objEnterPrise.checkError("div", "You can't create duplicate Organization.")).to eq true
          puts "Duplicate Organization cannot be created"

          @testRailUtility.postResult(869, "comment", 1, @run)
        rescue Exception => e
          Rollbar.error(e)
          @testRailUtility.postResult(869, e, 5, @run)
          puts e
          raise e
        end
      end

      it 'C1011: To check contact can be created from create opportunity page' do
        begin
          @objEnterPrise.createNewContact("Enzigma Enterprise 01", "Test Contact1", "contacttest@demo.com")
          contactId = @objEnterPrise.getContactFields("contacttest@demo.com").fetch("Id")
          expect(contactName = @objEnterPrise.getContactFields("contacttest@demo.com").fetch("Name")).to eq "Test Contact1"
          puts "New Contact is successfully created"
          Salesforce.addRecordsToDelete("Contact", "#{contactId}")
          @testRailUtility.postResult(1011, "comment", 1, @run)
        rescue Exception => e
          Rollbar.error(e)
          @testRailUtility.postResult(1011, e, 5, @run)
          puts e
          raise e
        end
      end

      it 'C870: To check opportunity is created with stage "Qualifying"' do
        begin
          recordId = @objEnterPrise.createOpportunity("Primary Member", "Amit Kasar NMD", "CHI-National Building", "Enzigma Enterprise 01", nil, "2", "100")
          #puts "recordId: #{recordId}"
          #puts SfRESTService.getDataByQuery("SELECT+name+from+OpportunityTeamMember+WHERE+opportunityId+=+'#{recordId}'", "/services/data/v41.0/query/?q=", false)
          #puts SfRESTService.getDataByQuery("SELECT+name+from+OpportunityTeamMember+WHERE+opportunityId+=+'0061D000002b4ZeQAI'", "/services/data/v41.0/query/?q=", false)
          oppDetails = @objEnterPrise.getOpportunityFields(recordId)

          expect(oppDetails.fetch("StageName")).to eq "Qualifying"
          puts "Opportunity is successfully created with stage as Qualifying"
          expect(oppDetails.fetch("Stage_Details__c")).to eq "Qualify Opportunity"
          puts "Opportunity is successfully created with stage detail as Qualify Opportunity"
          Salesforce.addRecordsToDelete("Opportunity", "#{recordId}")
          @testRailUtility.postResult(870, "comment", 1, @run)
        rescue Exception => e
          Rollbar.error(e)
          @testRailUtility.postResult(870, e, 5, @run)
          puts e
          raise e
        end
      end

      it 'C873: To check opportunity is created with stage "Selling".' do
        begin
          recordId = @objEnterPrise.createOpportunity("Decision Maker", "Amit Kasar NMD", "CHI-National Building", "Enzigma Enterprise 01", nil, "2", "100", nil, nil, "2018-2-23", nil, "2", nil)
          #puts "recordId: #{recordId}"
          oppDetails = @objEnterPrise.getOpportunityFields(recordId)
          expect(oppDetails.fetch("StageName")).to eq "Selling"
          puts "Opportunity is successfully created with Stage as Selling"
          expect(oppDetails.fetch("Stage_Details__c")).to eq "Sales Rep Searching Space"
          puts "Opportunity is successfully created with Stage Details as Sales Rep Searching Space"
          Salesforce.addRecordsToDelete("Opportunity", "#{recordId}")
          #sleep(120)

          @testRailUtility.postResult(873, "comment", 1, @run)
        rescue Exception => e
          Rollbar.error(e)
          @testRailUtility.postResult(873, e, 5, @run)
          puts e
          raise e
        end
      end


      it 'C953: To check opportunity is created through global action where opportunity is Decision maker' do
        begin
          recordId = @objEnterPrise.createOpportunity("Decision Maker", "Amit Kasar NMD", "CHI-National Building", "Enzigma Enterprise 01", nil, "2", "100")
          #puts "recordId: #{recordId}"

          createdOpp = @objEnterPrise.getOpportunityFields(recordId)
          #puts "createdOpp: #{createdOpp}"

          oppRoleFieldDetails = @objEnterPrise.getOpportunity_RoleFields(recordId)
          #puts "oppRoleFieldDetails: #{oppRoleFieldDetails}"

          expect(createdOpp.fetch("StageName")).to eq "Qualifying"
          puts "Opportunity is created with stage as Qualifying"

          expect(createdOpp.fetch("Stage_Details__c")).to eq "Qualify Opportunity"
          puts "Opportunity is successfully created with stage detail as Qualify Opportunity"

          expect(createdOpp.fetch("Opportunity_Account_Name__c")).to eq "Enzigma Enterprise 01"
          puts "Opportunity is successfully created with Account Name as Enzigma Enterprise 01"

          expect(createdOpp.fetch("Owner_Auto_Assign__c")).to eq "true"
          puts "Opportunity Owner Auto Assign field is successfully checked."

          expect(createdOpp.fetch("Decision_Maker__r.Name")).to eq "Amit Kasar NMD"
          puts "Opportunity Decision Maker is successfully Assigned."

          #buildingId = @objEnterPrise.getOpportunityFields(recordId).fetch("Building__c")
          buildingId = createdOpp.fetch("Building__c")
          buildingDetails = @objEnterPrise.getBuildingFields(buildingId)
          expect(buildingDetails.fetch("Name")).to eq "CHI-National Building"
          puts "Opportunity Building name is successfully Assigned."

          expect(oppRoleFieldDetails.fetch("Id")).not_to eq nil
          puts "Opportunity Role is successfully Created"

          expect(oppRoleFieldDetails.fetch("Is_Primary_Member__c")).to eq "false"
          puts "Is Primary Member field of opportunity role is successfully Unchecked"

          expect(oppRoleFieldDetails.fetch("Role__c")).to eq "Decision Maker"
          puts "Opportunity role has been successfully assigned as Decision Maker"

          opportunityTeamMemberDetails = SfRESTService.getDataByQuery("SELECT+TeamMemberRole+,+User.Name+from+OpportunityTeamMember+WHERE+opportunityId+=+'#{recordId}'", "/services/data/v41.0/query/?q=", false)
          expect(opportunityTeamMemberDetails['records'][0]['TeamMemberRole']).to eq "Sales Rep"
          puts "Opportunity team member role has been successfully assigned as Sales Rep"

          oppOwnerName = createdOpp.fetch("Owner.Name")
          oppTeamMemberUser = opportunityTeamMemberDetails['records'][0]['User']['Name']
          expect(oppOwnerName).to eq oppTeamMemberUser
          puts "User field of Opportunity Team Member is successfully assigned as same as opportunity Owner Name."
          #opportunityTeamMemberRole = SfRESTService.getDataByQuery("SELECT+User.Name+from+OpportunityTeamMember+WHERE+opportunityId+=+'#{recordId}'", "/services/data/v41.0/query/?q=", false)

          Salesforce.addRecordsToDelete("Opportunity", "#{recordId}")
          #accountId = @objEnterPrise.getOpportunityFields(recordId).fetch("AccountId")
          #expect(@objEnterPrise.getAccountFieldsById(accountId).fetch("Primary_Member__c "))
          #expect(@objEnterPrise.getOpportunityFields(recordId).fetch("Main_Contact_ID__c")).to eq ""

          @testRailUtility.postResult(953, "comment", 1, @run)
        rescue Exception => e
          Rollbar.error(e)
          @testRailUtility.postResult(953, e, 5, @run)
          puts e
          raise e
        end
      end


      it 'C867: To check opportunity is created through global action where opportunity is Primary Member' do
        begin
          recordId = @objEnterPrise.createOpportunity("Primary Member", "Amit Kasar NMD", "CHI-National Building", "Enzigma Enterprise 01", nil, "2", "100")
          #puts "recordId: #{recordId}"

          createdOpp = @objEnterPrise.getOpportunityFields(recordId)
          #puts "createdOpp: #{createdOpp}"

          oppRoleFieldDetails = @objEnterPrise.getOpportunity_RoleFields(recordId)
          #puts "oppRoleFieldDetails: #{oppRoleFieldDetails}"

          expect(createdOpp.fetch("StageName")).to eq "Qualifying"
          puts "Opportunity is created with stage as Qualifying"

          expect(createdOpp.fetch("Stage_Details__c")).to eq "Qualify Opportunity"
          puts "Opportunity is created with stage detail as Qualify Opportunity"

          expect(createdOpp.fetch("Opportunity_Account_Name__c")).to eq "Enzigma Enterprise 01"
          puts "Opportunity is created with Account Name as Enzigma Enterprise 01"

          expect(createdOpp.fetch("Owner_Auto_Assign__c")).to eq "true"
          puts "Opportunity Owner Auto Assign field is successfully checked."

          #contactId = @objEnterPrise.getOpportunityFields(recordId).fetch("Decision_Maker__c")
          #contactId = createdOpp.fetch("Decision_Maker__c")
          #contactDetails = @objEnterPrise.getContactFieldsById(contactId)
          #expect(contactDetails.fetch("Name")).to eq "Amit Kasar NMD"
          #puts "Opportunity Decision Maker is Successfully Assigned."

          expect(createdOpp.fetch("Decision_Maker__r.Name")).to be_empty
          puts "Opportunity Decision Maker is successfully Empty."

          #buildingId = @objEnterPrise.getOpportunityFields(recordId).fetch("Building__c")
          buildingId = createdOpp.fetch("Building__c")
          buildingDetails = @objEnterPrise.getBuildingFields(buildingId)
          expect(buildingDetails.fetch("Name")).to eq "CHI-National Building"
          puts "Opportunity Building name is successfully Assigned."

          expect(oppRoleFieldDetails.fetch("Id")).not_to eq nil
          puts "Opportunity Role is successfully Created"

          expect(oppRoleFieldDetails.fetch("Is_Primary_Member__c")).to eq "true"
          puts "Is Primary Member field of opportunity role is Successfully checked"

          expect(oppRoleFieldDetails.fetch("Role__c")).to eq "Primary Member"
          puts "Opportunity role has been successfully assigned as Primary Member"

          opportunityTeamMemberDetails = SfRESTService.getDataByQuery("SELECT+TeamMemberRole+,+User.Name+from+OpportunityTeamMember+WHERE+opportunityId+=+'#{recordId}'", "/services/data/v41.0/query/?q=", false)
          expect(opportunityTeamMemberDetails['records'][0]['TeamMemberRole']).to eq "Sales Rep"
          puts "Opportunity team member role has been successfully assigned as Sales Rep"

          oppOwnerName = createdOpp.fetch("Owner.Name")
          oppTeamMemberUser = opportunityTeamMemberDetails['records'][0]['User']['Name']
          expect(oppOwnerName).to eq oppTeamMemberUser
          puts "User field of Opportunity Team Member is successfully assigned as same as opportunity Owner Name."
          #opportunityTeamMemberRole = SfRESTService.getDataByQuery("SELECT+User.Name+from+OpportunityTeamMember+WHERE+opportunityId+=+'#{recordId}'", "/services/data/v41.0/query/?q=", false)

          Salesforce.addRecordsToDelete("Opportunity", "#{recordId}")
          #accountId = @objEnterPrise.getOpportunityFields(recordId).fetch("AccountId")
          #expect(@objEnterPrise.getAccountFieldsById(accountId).fetch("Primary_Member__c "))
          #expect(@objEnterPrise.getOpportunityFields(recordId).fetch("Main_Contact_ID__c")).to eq ""

          @testRailUtility.postResult(867, "comment", 1, @run)
        rescue Exception => e
          Rollbar.error(e)
          @testRailUtility.postResult(867, e, 5, @run)
          puts e
          raise e
        end
      end

      it 'C954: To check opportunity is created through global action where opportunity is Primary Contact' do
        begin
          recordId = @objEnterPrise.createOpportunity("Primary Contact", "Amit Kasar NMD", "CHI-National Building", "Enzigma Enterprise 01", nil, "2", "100")
          #puts "recordId: #{recordId}"

          createdOpp = @objEnterPrise.getOpportunityFields(recordId)
          #puts "createdOpp: #{createdOpp}"

          oppRoleFieldDetails = @objEnterPrise.getOpportunity_RoleFields(recordId)
          #puts "oppRoleFieldDetails: #{oppRoleFieldDetails}"

          expect(createdOpp.fetch("StageName")).to eq "Qualifying"
          puts "Opportunity is created with stage as Qualifying"

          expect(createdOpp.fetch("Stage_Details__c")).to eq "Qualify Opportunity"
          puts "Opportunity is created with stage detail as Qualify Opportunity"

          expect(createdOpp.fetch("Opportunity_Account_Name__c")).to eq "Enzigma Enterprise 01"
          puts "Opportunity is created with Account Name as Enzigma Enterprise 01"

          expect(createdOpp.fetch("Owner_Auto_Assign__c")).to eq "true"
          puts "Opportunity Owner Auto Assign field is successfully checked."

          #contactId = @objEnterPrise.getOpportunityFields(recordId).fetch("Decision_Maker__c")
          expect(createdOpp.fetch("Decision_Maker__r.Name")).to be_empty
          puts "Opportunity Decision Maker is successfully Empty."

          #buildingId = @objEnterPrise.getOpportunityFields(recordId).fetch("Building__c")
          buildingId = createdOpp.fetch("Building__c")
          buildingDetails = @objEnterPrise.getBuildingFields(buildingId)
          expect(buildingDetails.fetch("Name")).to eq "CHI-National Building"
          puts "Opportunity Building name is successfully Assigned."

          expect(oppRoleFieldDetails.fetch("Id")).not_to eq nil
          puts "Opportunity Role is successfully Created"

          expect(oppRoleFieldDetails.fetch("Is_Primary_Member__c")).to eq "false"
          puts "Is Primary Member field of opportunity role is successfully Unchecked"

          expect(oppRoleFieldDetails.fetch("Role__c")).to eq "Primary Contact"
          puts "Opportunity role has been successfully assigned as Primary Contact"

          opportunityTeamMemberDetails = SfRESTService.getDataByQuery("SELECT+TeamMemberRole+,+User.Name+from+OpportunityTeamMember+WHERE+opportunityId+=+'#{recordId}'", "/services/data/v41.0/query/?q=", false)
          expect(opportunityTeamMemberDetails['records'][0]['TeamMemberRole']).to eq "Sales Rep"
          puts "Opportunity team member role has been successfully assigned as Sales Rep"

          oppOwnerName = createdOpp.fetch("Owner.Name")
          oppTeamMemberUser = opportunityTeamMemberDetails['records'][0]['User']['Name']
          expect(oppOwnerName).to eq oppTeamMemberUser
          puts "User field of Opportunity Team Member is successfully assigned as same as opportunity Owner Name."
          #opportunityTeamMemberRole = SfRESTService.getDataByQuery("SELECT+User.Name+from+OpportunityTeamMember+WHERE+opportunityId+=+'#{recordId}'", "/services/data/v41.0/query/?q=", false)

          Salesforce.addRecordsToDelete("Opportunity", "#{recordId}")
          #accountId = @objEnterPrise.getOpportunityFields(recordId).fetch("AccountId")
          #expect(@objEnterPrise.getAccountFieldsById(accountId).fetch("Primary_Member__c "))
          #expect(@objEnterPrise.getOpportunityFields(recordId).fetch("Main_Contact_ID__c")).to eq ""

          @testRailUtility.postResult(954, "comment", 1, @run)
        rescue Exception => e
          Rollbar.error(e)
          @testRailUtility.postResult(954, e, 5, @run)
          puts e
          raise e
        end
      end

      it 'C955: To check opportunity is created through global action where opportunity is Influencer' do
        begin
          recordId = @objEnterPrise.createOpportunity("Influencer", "Amit Kasar NMD", "CHI-National Building", "Enzigma Enterprise 01", nil, "2", "100")
          #puts "recordId: #{recordId}"

          createdOpp = @objEnterPrise.getOpportunityFields(recordId)
          #puts "createdOpp: #{createdOpp}"

          oppRoleFieldDetails = @objEnterPrise.getOpportunity_RoleFields(recordId)
          #puts "oppRoleFieldDetails: #{oppRoleFieldDetails}"

          expect(createdOpp.fetch("StageName")).to eq "Qualifying"
          puts "Opportunity is created with stage as Qualifying"

          expect(createdOpp.fetch("Stage_Details__c")).to eq "Qualify Opportunity"
          puts "Opportunity is created with stage detail as Qualify Opportunity"

          expect(createdOpp.fetch("Opportunity_Account_Name__c")).to eq "Enzigma Enterprise 01"
          puts "Opportunity is created with Account Name as Enzigma Enterprise 01"

          expect(createdOpp.fetch("Owner_Auto_Assign__c")).to eq "true"
          puts "Opportunity Owner Auto Assign field is successfully checked."

          #contactId = @objEnterPrise.getOpportunityFields(recordId).fetch("Decision_Maker__c")
          expect(createdOpp.fetch("Decision_Maker__r.Name")).to be_empty
          puts "Opportunity Decision Maker is successfully Empty."

          #buildingId = @objEnterPrise.getOpportunityFields(recordId).fetch("Building__c")
          buildingId = createdOpp.fetch("Building__c")
          buildingDetails = @objEnterPrise.getBuildingFields(buildingId)
          expect(buildingDetails.fetch("Name")).to eq "CHI-National Building"
          puts "Opportunity Building name is successfully Assigned."

          expect(oppRoleFieldDetails.fetch("Id")).not_to eq nil
          puts "Opportunity Role is successfully Created"

          expect(oppRoleFieldDetails.fetch("Is_Primary_Member__c")).to eq "false"
          puts "Is Primary Member field of opportunity role is successfully Unchecked"

          expect(oppRoleFieldDetails.fetch("Role__c")).to eq "Influencer"
          puts "Opportunity role has been successfully assigned as Influencer"

          opportunityTeamMemberDetails = SfRESTService.getDataByQuery("SELECT+TeamMemberRole+,+User.Name+from+OpportunityTeamMember+WHERE+opportunityId+=+'#{recordId}'", "/services/data/v41.0/query/?q=", false)
          expect(opportunityTeamMemberDetails['records'][0]['TeamMemberRole']).to eq "Sales Rep"
          puts "Opportunity team member role has been successfully assigned as Sales Rep"

          oppOwnerName = createdOpp.fetch("Owner.Name")
          oppTeamMemberUser = opportunityTeamMemberDetails['records'][0]['User']['Name']
          expect(oppOwnerName).to eq oppTeamMemberUser
          puts "User field of Opportunity Team Member is successfully assigned as same as opportunity Owner Name."
          #opportunityTeamMemberRole = SfRESTService.getDataByQuery("SELECT+User.Name+from+OpportunityTeamMember+WHERE+opportunityId+=+'#{recordId}'", "/services/data/v41.0/query/?q=", false)

          Salesforce.addRecordsToDelete("Opportunity", "#{recordId}")
          #accountId = @objEnterPrise.getOpportunityFields(recordId).fetch("AccountId")
          #expect(@objEnterPrise.getAccountFieldsById(accountId).fetch("Primary_Member__c "))
          #expect(@objEnterPrise.getOpportunityFields(recordId).fetch("Main_Contact_ID__c")).to eq ""

          @testRailUtility.postResult(955, "comment", 1, @run)
        rescue Exception => e
          Rollbar.error(e)
          @testRailUtility.postResult(955, e, 5, @run)
          puts e
          raise e
        end
      end

      it 'C957: To check opportunity is created through global action where opportunity is Broker' do
        begin
          recordId = @objEnterPrise.createOpportunity("Broker", "Amit Kasar NMD", "CHI-National Building", "Enzigma Enterprise 01", nil, "2", "100")
          #puts "recordId: #{recordId}"

          createdOpp = @objEnterPrise.getOpportunityFields(recordId)
          #puts "createdOpp: #{createdOpp}"

          oppRoleFieldDetails = @objEnterPrise.getOpportunity_RoleFields(recordId)
          #puts "oppRoleFieldDetails: #{oppRoleFieldDetails}"

          expect(createdOpp.fetch("StageName")).to eq "Qualifying"
          puts "Opportunity is created with stage as Qualifying"

          expect(createdOpp.fetch("Stage_Details__c")).to eq "Qualify Opportunity"
          puts "Opportunity is created with stage detail as Qualify Opportunity"

          expect(createdOpp.fetch("Opportunity_Account_Name__c")).to eq "Enzigma Enterprise 01"
          puts "Opportunity is created with Account Name as Enzigma Enterprise 01"

          expect(createdOpp.fetch("Owner_Auto_Assign__c")).to eq "true"
          puts "Opportunity Owner Auto Assign field is successfully checked."

          #contactId = @objEnterPrise.getOpportunityFields(recordId).fetch("Decision_Maker__c")
          expect(createdOpp.fetch("Decision_Maker__r.Name")).to be_empty
          puts "Opportunity Decision Maker is successfully Empty."

          #buildingId = @objEnterPrise.getOpportunityFields(recordId).fetch("Building__c")
          buildingId = createdOpp.fetch("Building__c")
          buildingDetails = @objEnterPrise.getBuildingFields(buildingId)
          expect(buildingDetails.fetch("Name")).to eq "CHI-National Building"
          puts "Opportunity Building name is successfully Assigned."

          expect(oppRoleFieldDetails.fetch("Id")).not_to eq nil
          puts "Opportunity Role is successfully Created"

          expect(oppRoleFieldDetails.fetch("Is_Primary_Member__c")).to eq "false"
          puts "Is Primary Member field of opportunity role is successfully Unchecked"

          expect(oppRoleFieldDetails.fetch("Role__c")).to eq "Broker"
          puts "Opportunity role has been successfully assigned as Broker"

          opportunityTeamMemberDetails = SfRESTService.getDataByQuery("SELECT+TeamMemberRole+,+User.Name+from+OpportunityTeamMember+WHERE+opportunityId+=+'#{recordId}'", "/services/data/v41.0/query/?q=", false)
          expect(opportunityTeamMemberDetails['records'][0]['TeamMemberRole']).to eq "Sales Rep"
          puts "Opportunity team member role has been successfully assigned as Sales Rep"

          oppOwnerName = createdOpp.fetch("Owner.Name")
          oppTeamMemberUser = opportunityTeamMemberDetails['records'][0]['User']['Name']
          expect(oppOwnerName).to eq oppTeamMemberUser
          puts "User field of Opportunity Team Member is successfully assigned as same as opportunity Owner Name."
          #opportunityTeamMemberRole = SfRESTService.getDataByQuery("SELECT+User.Name+from+OpportunityTeamMember+WHERE+opportunityId+=+'#{recordId}'", "/services/data/v41.0/query/?q=", false)

          Salesforce.addRecordsToDelete("Opportunity", "#{recordId}")
          #accountId = @objEnterPrise.getOpportunityFields(recordId).fetch("AccountId")
          #expect(@objEnterPrise.getAccountFieldsById(accountId).fetch("Primary_Member__c "))
          #expect(@objEnterPrise.getOpportunityFields(recordId).fetch("Main_Contact_ID__c")).to eq ""

          @testRailUtility.postResult(957, "comment", 1, @run)
        rescue Exception => e
          Rollbar.error(e)
          @testRailUtility.postResult(957, "comment", 5, @run)
          puts e
          raise e
        end
      end

      it "Record Deletion" do
        @objEnterPrise.delRecord("Account")
        @objEnterPrise.delRecord("Opportunity")
        @objEnterPrise.delRecord("Contact")
      end

      it 'logout from current user' do
        @objEnterPrise.logOut()
      end

      after(:example) {
        puts "-----------------------------------------------------------------------------------------------"
      }
    end
  end

  before(:all) {
    #include SauceLabs
    #SauceLab will read env variable and accordingly set browser
    #@driver = SauceLabs.selenium_driver()
    @driver = Selenium::WebDriver.for ENV['BROWSER'].to_sym
    @objEnterPrise = EnterPrise.new(@driver)
    testRecordFile = File.open(File.expand_path(Dir.pwd + '/Enterprise/TestData/UserSettings.json', "r"))
    #testRecordFile = File.open("E:/Projects/WeWork/SF-QA-Automation/Enterprise/TestData/UserSettings.json", "r" )
    testRecordsInJson = testRecordFile.read()
    @testRecords = JSON.parse(testRecordsInJson)

    file = File.open("timeSettings.yaml", "r")
    @timeSetting = YAML.load(file.read())

    config = YAML.load_file('credentials.yaml')

    @testRailUtility = EnziTestRailUtility::TestRailUtility.new(config['TestRail']['username'], config['TestRail']['password'])
    #@run = @testRailUtility.addRun("EnterPriseRun", 4, @testRailUtility.getSuitByName(4, "Enterprise"))
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
      @run = @testRailUtility.addRun("EnterPrise Run", 4, 30, arrCaseIds)['id']
    else
      @run = ENV['RUN_ID']
    end
    if ENV['RUN_ID'].nil? then
      @runId = @testRailUtility.addRun("EnterPrise Run", 4, 30, arrCaseIds)['id']
    end
=end

    @run = ENV['RUN_ID']
  }

  context 'Navigaton to Manage Users' do
    it "should go to Home page", :sanity => true do
      puts "---------------------------------------------------------------------------------------"
      if expect(@objEnterPrise.getDriver.title).to eq "Salesforce - Unlimited Edition"
        puts "Successfully redirected to Home Page"
      end
      @objEnterPrise.redirectToUsers()
      puts "Successfully redirected to Manage Users Page"
      EnziUIUtility.selectOption(@driver, :id, "fcf", "Enterprise Demo Users")
      #EnziUIUtility.wait(@driver,nil,nil,10)
      puts "Successfully selected Enterprise Demo Users" #c1 s2 r d s n r3 m4 n s
      puts "---------------------------------------------------------------------------------------"
    end
  end

  context 'Navigation to Different Profiles' do
    index = 1
    loop do
      include_examples "test", index
      index = index + 1
      if index == 6
        break
      end
    end
  end

  after (:all) {
    @driver.quit
  }
end

#Created By : Monika Pingale
#Created Date : 18th Jan 2018
#Purpose: This class contains specs related to salesforce rest web service
#Modified date :
require "rspec"
#require 'rspec/repeat'
require 'date'
#require_relative "helper.rb"
require 'salesforce'
require 'securerandom'
require_relative File.expand_path(Dir.pwd+"/CustomRESTAPI/PageObjects/sfRESTService.rb")
require_relative File.expand_path("GemUtilities/EnziTestRailUtility/lib/EnziTestRailUtility.rb")

describe SfRESTService do
  before(:all){
    testDataFile = File.open(Dir.pwd+"/CustomRESTAPI//TestData/testData.json", "r")
    testDataInJson = testDataFile.read()
    @testData = JSON.parse(testDataInJson)
    SfRESTService.loginRequest
    @salesforceBulk = ARGV[1]
    profileAndSandBoxType = ARGV[0].split(',')
    @objSFRest = SfRESTService.new(config[profileAndSandBoxType[0]][profileAndSandBoxType[1]]['grant_type'],config[profileAndSandBoxType[0]][profileAndSandBoxType[1]]['client_id'],config[profileAndSandBoxType[0]][profileAndSandBoxType[1]]['client_secret'],config[profileAndSandBoxType[0]][profileAndSandBoxType[1]]['username'],config[profileAndSandBoxType[0]][profileAndSandBoxType[1]]['password'])
    #@salesforceBulk = Salesforce.login(SfRESTService.class_variable_get(:@@credentails)['QAAuto']['username'],SfRESTService.class_variable_get(:@@credentails)['QAAuto']['password'],true)
    config = YAML.load_file('credentials.yaml')
    @timeSettingMap = YAML.load_file(Dir.pwd+'/timeSettings.yaml')
    @testRailUtility = EnziTestRailUtility::TestRailUtility.new(config['TestRail']['username'],config['TestRail']['password'])
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
      @runId = @testRailUtility.addRun("RESTAPI Tour Service",4,26,arrCaseIds)['id']
    else
      @runId = ENV['RUN_ID']
    end
    if ENV['RUN_ID'].nil? then
      @runId = @testRailUtility.addRun("RESTAPI Tour Service",4,26,arrCaseIds)['id']
    end
=end
    @runId = ENV['RUN_ID']
  }

  before(:each){
    puts "\n"
    puts "---------------------------------------------------------------------------------------------------------------------------"
  }

  it "C344 : To check tour is created from restapi" , :"344"=>true do
    puts "C344 : To check tour is created from restapi"
    begin
      payloadHash = JSON.parse(@testRailUtility.getPayloadsFromSteps(@testRailUtility.getCase(344)['custom_steps_separated'])[0]['expected'])
      payloadHash['body']['email'] = "test_HP#{rand(900000)}@example.com"
      buildingTestData = @testData['Building']
      buildingTestData[0]['uuid__c'] = SecureRandom.uuid
      payloadHash['body']['tour_building_uuid'] = Salesforce.getRecords(@salesforceBulk,"Building__c","SELECT UUID__c FROM Building__c WHERE id = '#{Salesforce.createRecords(@salesforceBulk,"Building__c",@testData['Building'])[0]['Id']}'",nil).result.records[0].fetch('UUID__c')
      getResponse = @objSFRest.postData(''+payloadHash.to_json,"#{@testData['ServiceUrls'][0]['tour']}")
      puts "\n"
      sleep(@timeSettingMap['Sleep']['Environment']['Classic'])
      puts "Checking service call response..."
      expect(getResponse['success']).to be true
      expect(getResponse['result']).to_not eql nil
      Salesforce.addRecordsToDelete('Tour',getResponse['result'])
      puts "Service call response is #{getResponse['success']}"
      puts "\n"
      @testRailUtility.postResult(344,"Result for case 344 is #{getResponse['success']}",1,@runId)
    rescue Exception => excp
      @testRailUtility.postResult(344,"Result for case 344 is #{excp}",5,@runId)
      raise excp
    end
  end
  it "To check tour is created and contact is created in account whose uuid is passed in payload" , :"767" => true do
    puts "C767 : To check tour is created and contact is created in account whose uuid is passed in payload"
    begin
      account = Salesforce.createRecords(@salesforceBulk,"Account",@testData['Account'])
      puts "\n"
      puts "Checking account insertion..."
      expect(account[0]['Id']).to_not eql nil
      puts "Account created successfully"
      payloadHash = JSON.parse(@testRailUtility.getPayloadsFromSteps(@testRailUtility.getCase(767)['custom_steps_separated'])[0]['expected'])
      payloadHash['body']['email'] = "test_HP#{rand(900000)}@example.com"
      buildingTestData = @testData['Building']
      buildingTestData[0]['uuid__c'] = SecureRandom.uuid
      payloadHash['body']['buildings_interested_uuids'][0] = Salesforce.getRecords(@salesforceBulk,"Building__c","SELECT UUID__c FROM Building__c WHERE id = '#{Salesforce.createRecords(@salesforceBulk,"Building__c",@testData['Building'])[0]['Id']}'",nil).result.records[0].fetch('UUID__c')
      createdAccount = Salesforce.getRecords(@salesforceBulk,"Account","SELECT UUID__c,Number_Of_Open_Opportunities__c FROM Account WHERE id = '#{account[0]['Id']}'",nil).result.records[0]
      payloadHash['body']['account_uuid'] = createdAccount.fetch('UUID__c')
      getResponse = @objSFRest.postData(''+payloadHash.to_json,"#{@testData['ServiceUrls'][0]['tour']}")
      puts "\n"
      sleep(@timeSettingMap['Sleep']['Environment']['Classic'])
      puts "Checking service call response..."
      expect(getResponse['success']).to be true
      expect(getResponse['result']).to_not eql nil
      Salesforce.addRecordsToDelete('Tour',getResponse['result'])
      puts "Service call response is #{getResponse['success']}"
      puts "\n"
      puts "Checking contact creation for given account uuid..."
      createdContact = Salesforce.getRecords(@salesforceBulk,"Contact","SELECT id,Account.Name FROM Contact WHERE Account.id = '#{account[0]['Id']}'",nil).result.records[0]
      expect(createdContact.fetch('Id')).to_not eql nil
      expect(createdContact.fetch('Account.Name')).to eql @testData['Account'][0]['Name']
      Salesforce.addRecordsToDelete('Contact',createdContact.fetch('Id'))
      puts "Contact created successfully"
      puts "\n"
      if createdAccount.fetch('Number_Of_Open_Opportunities__c').eql?('0') then
        puts "Checking opportunity creation..."
        createdOpportunity = Salesforce.getRecords(@salesforceBulk,"Opportunity","SELECT id FROM Opportunity WHERE Account.id = '#{account[0]['Id']}'",nil).result.records[0].fetch('Id')
        expect(createdOpportunity).to_not eql nil
        Salesforce.addRecordsToDelete('Opportunity',createdOpportunity)
        puts "Opportunity created successfully"
        puts "\n"
      end
      puts "\n"
      puts "Checking open activities..."
      expect(Salesforce.getRecords(@salesforceBulk,'Task',"SELECT id FROM Task WHERE WhatId = '#{getResponse['result'].delete('"')}'",nil).result.records[0].fetch('Id')).to_not eql nil
      puts "Open activities created successfully"
      @testRailUtility.postResult(767,"Result for case 767 is #{getResponse['success']}",1,@runId)
    rescue Exception => excp
      @testRailUtility.postResult(767,"Result for case 767 is #{excp}",5,@runId)
      raise excp
    end
  end

  it "To check 'Get' functionality" , :"863" => true do
    puts "C863 : To check 'Get' functionality"
    begin
      postResponse = @objSFRest.getData(SfRESTService.class_variable_get(:@@postedData).delete('"'),"#{@testData['ServiceUrls'][0]['tour']}")

      #postResponse = SfRESTService.getData('a0R3D0000011j84',"#{@testData['ServiceUrls'][0]['tour']}",true)
      puts postResponse
      expect(postResponse['success']).to be true
      expect(postResponse.parsed_response['result']['tour_id']).to_not eql nil
      @testRailUtility.postResult(863,"Result for case 863 is #{postResponse['success']}",1,@runId)
    rescue Exception => excp
      @testRailUtility.postResult(863,"Result for case 863 is #{excp}",5,@runId)
      raise excp
    end
  end
  it "To check tour is booked and account, contact, opportunity is created" , :"773" => true do
    puts "C773 : To check tour is booked and account, contact, opportunity is created"
    begin
      payloadHash = JSON.parse(@testRailUtility.getPayloadsFromSteps(@testRailUtility.getCase(773)['custom_steps_separated'])[0]['expected'])
      payloadHash['body']['email'] = "test_HP#{rand(900000)}@example.com"
      buildingTestData = @testData['Building']
      buildingTestData[0]['uuid__c'] = SecureRandom.uuid
      payloadHash['body']['buildings_interested_uuids'][0] = Salesforce.getRecords(@salesforceBulk,"Building__c","SELECT UUID__c FROM Building__c WHERE id = '#{Salesforce.createRecords(@salesforceBulk,"Building__c",@testData['Building'])[0]['Id']}'",nil).result.records[0].fetch('UUID__c')

      getResponse = @objSFRest.postData(''+payloadHash.to_json,"#{@testData['ServiceUrls'][0]['tour']}",)
      puts "\n"
      sleep(@timeSettingMap['Sleep']['Environment']['Classic'])
      puts "Checking service call response..."
      expect(getResponse['success']).to be true
      expect(getResponse['result']).to_not eql nil
      Salesforce.addRecordsToDelete('Tour',getResponse['result'].delete('"'))
      puts "Service call response is #{getResponse['success']}"
      puts "\n"
      puts "Checking contact creation"
      expect(Salesforce.getRecords(@salesforceBulk,"Contact","SELECT id FROM Contact WHERE Email = '#{payloadHash['body']['email']}'",nil).result.records[0].fetch('Id')).to_not eql nil
      puts "Contact created successfully"
      puts "\n"
      puts "Checking account creation"
      createdAccount = Salesforce.getRecords(@salesforceBulk,"Account","SELECT id FROM Account WHERE name = '#{payloadHash['body']['company_name']}'",nil).result.records[0].fetch('Id')
      expect(createdAccount).to_not eql nil
      Salesforce.addRecordsToDelete('Account',createdAccount)
      puts "Contact created successfully"
      puts "\n"
      puts "Checking opportunity creation..."
      createdOpportunity = Salesforce.getRecords(@salesforceBulk,"Opportunity","SELECT id FROM Opportunity WHERE Account.name = '#{payloadHash['body']['company_name']}'",nil).result.records[0].fetch('Id')
      expect(createdOpportunity).to_not eql nil
      Salesforce.addRecordsToDelete('Opportunity',createdOpportunity)
      puts "Opportunity created successfully"
      puts "\n"
      puts "Checking open activities..."
      expect(Salesforce.getRecords(@salesforceBulk,'Task',"SELECT id FROM Task WHERE WhatId = '#{getResponse['result'].delete('"')}'",nil).result.records[0].fetch('Id')).to_not eql nil
      puts "Open activities created successfully"
      @testRailUtility.postResult(773,"Result for case 773 is #{getResponse['success']}",1,@runId)
    rescue Exception => excp
      @testRailUtility.postResult(773,"Result for case 773 is #{excp}",5,@runId)
      raise excp
    end
  end

  it "To check tour is created when account_uuid and contact_uuid are provided where that contact should not be child of a account" , :"774" => true do
    puts "C774 : To check tour is created when account_uuid and contact_uuid are provided where that contact should not be child of a account"
    begin
      payloadHash = JSON.parse(@testRailUtility.getPayloadsFromSteps(@testRailUtility.getCase(774)['custom_steps_separated'])[0]['expected'])
      payloadHash['body']['email'] = "test_HP#{rand(900000)}@example.com"
      buildingTestData = @testData['Building']
      buildingTestData[0]['uuid__c'] = SecureRandom.uuid
      payloadHash['body']['buildings_interested_uuids'][0] = Salesforce.getRecords(@salesforceBulk,"Building__c","SELECT UUID__c FROM Building__c WHERE id = '#{Salesforce.createRecords(@salesforceBulk,"Building__c",@testData['Building'])[0]['Id']}'",nil).result.records[0].fetch('UUID__c')

      account = Salesforce.createRecords(@salesforceBulk,"Account",@testData['Account'])
      puts "\n"
      puts "Checking account insertion..."
      expect(account[0]['Id']).to_not eql nil
      puts "Account created successfully"
      contact = @testData['Contact']
      contact[0]['accountId'] = account[0]['Id']
      contact[0]['email'] = "test_enzi#{rand(900000)}@example.com"
      puts contact
      primaryMember = Salesforce.createRecords(@salesforceBulk,"Contact",contact)
      createdContact = Salesforce.getRecords(@salesforceBulk,"Contact","SELECT name,UUID__c,Email FROM Contact WHERE id = '#{primaryMember[0]['Id']}'",nil).result.records[0]
      createdAccount = Salesforce.getRecords(@salesforceBulk,"Account","SELECT UUID__c,Primary_Member__r.Email FROM Account WHERE id = '#{account[0]['Id']}'",nil).result.records[0]
      payloadHash['body']['account_uuid'] = createdAccount.fetch('UUID__c')
      payloadHash['body']['contact_uuid'] = createdContact.fetch('UUID__c')
      getResponse = @objSFRest.postData(''+payloadHash.to_json,"#{@testData['ServiceUrls'][0]['tour']}")
      puts "\n"
      sleep(@timeSettingMap['Sleep']['Environment']['Classic'])
      puts "Checking service call response..."
      expect(getResponse['success']).to be true
      expect(getResponse['result']).to_not eql nil
      Salesforce.addRecordsToDelete('Tour',getResponse['result'].delete('"'))
      puts "Service call response is #{getResponse['success']}"
      puts "\n"
      createdTour = Salesforce.getRecords(@salesforceBulk,"Tour_Outcome__c","SELECT Primary_Member__r.Name,Company_Name__c,Tour_Scheduled_With_Email__c FROM Tour_Outcome__c WHERE id = '#{getResponse['result'].delete('"')}'",nil).result.records[0]
      puts "Checking primary member on tour..."
      expect(createdTour.fetch('Primary_Member__r.Name')).to eql "#{contact[0]['firstName']} #{contact[0]['lastName']}"
      puts "Primary member is :: #{createdTour.fetch('Primary_Member__r.Name')}"
      puts "Primary member checked successfully"
      puts "\n"
      puts "Checking company name on tour..."
      expect(createdTour.fetch('Company_Name__c')).to eql @testData['Account'][0]['Name']
      puts "Company Name is :: #{createdTour.fetch('Company_Name__c')}"
      puts "Company Name checked successfully"
      puts "\n"
      puts "Checking tour scheduled with email on tour..."
      expect(createdTour.fetch('Tour_Scheduled_With_Email__c')).to eql createdContact.fetch('Email')
      puts "Tour scheduled with email is :: #{createdTour.fetch('Tour_Scheduled_With_Email__c')}"
      puts "Tour scheduled with email checked successfully"
      puts "\n"
      puts "Checking open activities..."
      expect(Salesforce.getRecords(@salesforceBulk,'Task',"SELECT id FROM Task WHERE WhatId = '#{getResponse['result'].delete('"')}'",nil).result.records[0].fetch('Id')).to_not eql nil
      puts "Open activities created successfully"
      puts "\n"
      @testRailUtility.postResult(774,"Result for case 774 is #{getResponse['success']}",1,@runId)
    rescue Exception => excp
      @testRailUtility.postResult(774,"Result for case 774 is #{excp}",5,@runId)
      raise excp
    end
  end

  it "To check tour is booked and location interested is added in open opportunity" do
    puts "C772 : To check tour is booked and location interested is added in open opportunity"
    begin
      account = Salesforce.createRecords(@salesforceBulk,"Account",@testData['Account'])
      puts "\n"
      puts "Checking account insertion..."
      expect(account[0]['Id']).to_not eql nil
      puts "Account created successfully"
      payloadHash = JSON.parse(@testRailUtility.getPayloadsFromSteps(@testRailUtility.getCase(772)['custom_steps_separated'])[0]['expected'])
      payloadHash['body']['email'] = "test_HP#{rand(900000)}@example.com"
      buildingTestData = @testData['Building']
      buildingTestData[0]['uuid__c'] = SecureRandom.uuid
      payloadHash['body']['buildings_interested_uuids'][0] = Salesforce.getRecords(@salesforceBulk,"Building__c","SELECT UUID__c FROM Building__c WHERE id = '#{Salesforce.createRecords(@salesforceBulk,"Building__c",@testData['Building'])[0]['Id']}'",nil).result.records[0].fetch('UUID__c')

      createdAccount = Salesforce.getRecords(@salesforceBulk,"Account","SELECT UUID__c,Number_Of_Open_Opportunities__c FROM Account WHERE id = '#{account[0]['Id']}'",nil).result.records[0]
      payloadHash['body']['account_uuid'] = createdAccount.fetch('UUID__c')
      payloadHash['body']['tour_building_uuid'] = Salesforce.getRecords(@salesforceBulk,"Building__c","SELECT UUID__c FROM Building__c WHERE name = 'LA-Santa Monica'",nil).result.records[0]
      getResponse = @objSFRest.postData(''+payloadHash.to_json,"#{@testData['ServiceUrls'][0]['tour']}")
      puts "\n"
      sleep(@timeSettingMap['Sleep']['Environment']['Classic'])
      puts "Checking service call response..."
      expect(getResponse['success']).to be true
      expect(getResponse['result']).to_not eql nil
      Salesforce.addRecordsToDelete('Tour',getResponse['result'].delete('"'))
      payloadHash['body']['tour_building_uuid'] = Salesforce.getRecords(@salesforceBulk,"Building__c","SELECT UUID__c FROM Building__c WHERE name = 'MAD-Paseo De La Castellana 77'",nil).result.records[0]
      getResponse2 = @objSFRest.postData(''+payloadHash.to_json,"#{@testData['ServiceUrls'][0]['tour']}")
      puts "\n"
      puts "Checking service call response..."
      expect(getResponse2['success']).to be true
      expect(getResponse2['result']).to_not eql nil
      Salesforce.addRecordsToDelete('Tour',getResponse2['result'].delete('"'))
      puts "Service call response is #{getResponse['success']}"
      puts "\n"
      puts "Checking contact creation for given account uuid..."
      createdContact = Salesforce.getRecords(@salesforceBulk,"Contact","SELECT id,Account.Name FROM Contact WHERE Account.id = '#{account[0]['Id']}'",nil).result.records[0]
      expect(createdContact.fetch('Id')).to_not eql nil
      expect(createdContact.fetch('Account.Name')).to eql @testData['Account'][0]['Name']
      puts "Contact created successfully"
      puts "\n"
      if createdAccount.fetch('Number_Of_Open_Opportunities__c').eql?('0') then
        puts "Checking opportunity creation..."
        createdOpportunity = Salesforce.getRecords(@salesforceBulk,"Opportunity","SELECT id,Locations_Interested__c FROM Opportunity WHERE Account.id = '#{account[0]['Id']}'",nil).result.records[0]
        expect(createdOpportunity.fetch('Id')).to_not eql nil
        puts createdOpportunity.fetch('Locations_Interested__c')
        expect(createdOpportunity.fetch('Locations_Interested__c')).to_not eql nil
        Salesforce.addRecordsToDelete('Opportunity',createdOpportunity.fetch('Id'))
        puts "Opportunity created successfully"
        puts "\n"
        puts "Checking open activities..."
        expect(Salesforce.getRecords(@salesforceBulk,'Task',"SELECT id FROM Task WHERE WhatId = '#{getResponse['result'].delete('"')}'",nil).result.records[0].fetch('Id')).to_not eql nil
        puts "Open activities created successfully"
        puts "\n"
      end
      @testRailUtility.postResult(772,"Result for case 772 is #{getResponse['success']}",1,@runId)
    rescue Exception => excp
      @testRailUtility.postResult(772,"Result for case 772 is #{excp}",5,@runId)
      raise excp
    end
  end
  it "To check owner of account, contact and opportunity changes when tour is booked" do
    puts "C775 : To check owner of account, contact and opportunity changes when tour is booked"
    begin
      account = Salesforce.createRecords(@salesforceBulk,"Account",@testData['Account'])
      puts "\n"
      puts "Checking account insertion..."
      expect(account[0]['Id']).to_not eql nil
      puts "Account created successfully"
      payloadHash = JSON.parse(@testRailUtility.getPayloadsFromSteps(@testRailUtility.getCase(775)['custom_steps_separated'])[0]['expected'])
      payloadHash['body']['email'] = "test_HP#{rand(900000)}@example.com"
      buildingTestData = @testData['Building']
      payloadHash['body']['company_name'] = @testData['Account'][0]['Name']
      buildingTestData = @testData['Building']
      buildingTestData[0]['uuid__c'] = SecureRandom.uuid
      payloadHash['body']['buildings_interested_uuids'][0] = Salesforce.getRecords(@salesforceBulk,"Building__c","SELECT UUID__c FROM Building__c WHERE id = '#{Salesforce.createRecords(@salesforceBulk,"Building__c",@testData['Building'])[0]['Id']}'",nil).result.records[0].fetch('UUID__c')

      getResponse = @objSFRest.postData(''+payloadHash.to_json,"#{@testData['ServiceUrls'][0]['tour']}")
      puts "\n"
      sleep(@timeSettingMap['Sleep']['Environment']['Classic'])
      puts "Checking service call response..."
      expect(getResponse['success']).to be true
      expect(getResponse['result']).to_not eql nil
      Salesforce.addRecordsToDelete('Tour',getResponse['result'].delete('"'))
      puts "Service call response is #{getResponse['success']}"
      puts "\n"
      buildingCommunityLead = Salesforce.getRecords(@salesforceBulk,"Building__c","SELECT Community_Lead__r.Name FROM Building__c WHERE UUID__c = '#{payloadHash['body']['tour_building_uuid']}'",nil).result.records[0].fetch('Community_Lead__r.Name')
      puts "Checking contact creation"
      createdContact = Salesforce.getRecords(@salesforceBulk,"Contact","SELECT id, Owner.Name FROM Contact WHERE Email = '#{payloadHash['body']['email']}'",nil).result.records[0]
      expect(createdContact.fetch('Id')).to_not eql nil
      Salesforce.addRecordsToDelete('Contact',createdContact.fetch('Id'))
      puts "Contact created successfully"
      puts "\n"
      puts "Checking owner of created contact"
      expect(createdContact.fetch('Owner.Name')).to eql buildingCommunityLead
      puts "\n"
      puts "Owner of created contact is :: #{createdContact.fetch('Owner.Name')}"
      puts "Contact owner checked successfully"
      puts "Checking account creation"
      createdAccount = Salesforce.getRecords(@salesforceBulk,"Account","SELECT id, Owner.Name, Number_Of_Open_Opportunities__c FROM Account WHERE id = '#{account[0]['Id']}'",nil).result.records[0]
      expect(createdAccount.fetch('Id')).to_not eql nil
      Salesforce.addRecordsToDelete('Account',createdAccount.fetch('Id'))
      puts "Account created successfully"
      puts "\n"
      #puts "Checking owner of created account"
      #expect(createdAccount.fetch('Owner.Name')).to eql buildingCommunityLead
      #puts "\n"
      #puts "Owner of created account is :: #{createdAccount.fetch('Owner.Name')}"
      #puts "Account owner checked successfully"
      puts "\n"
      puts "Checking opportunity creation..."
      if createdAccount.fetch('Number_Of_Open_Opportunities__c').eql?('0') then
        createdOpportunity = Salesforce.getRecords(@salesforceBulk,"Opportunity","SELECT id, Owner.Name FROM Opportunity WHERE Account.name = '#{payloadHash['body']['company_name']}'",nil).result.records[0]
        expect(createdOpportunity.fetch('Id')).to_not eql nil
        Salesforce.addRecordsToDelete('Opportunity',createdOpportunity.fetch('Id'))
        puts "Opportunity created successfully"
        puts "\n"
        puts "Checking owner of created opportunity"
        expect(createdOpportunity.fetch('Owner.Name')).to eql buildingCommunityLead
        puts "\n"
        puts "Owner of created opportunity is :: #{createdOpportunity.fetch('Owner.Name')}"
        puts "Opportunity owner checked successfully"
        puts "\n"
        puts "Checking open activities..."
        expect(Salesforce.getRecords(@salesforceBulk,'Task',"SELECT id FROM Task WHERE WhatId = '#{getResponse['result'].delete('"')}'",nil).result.records[0].fetch('Id')).to_not eql nil
        puts "Open activities created successfully"
        puts "\n"
      end
      @testRailUtility.postResult(775,"Result for case 775 is #{getResponse['success']}",1,@runId)
    rescue Exception => excp
      @testRailUtility.postResult(775,"Result for case 775 is #{excp}",5,@runId)
      raise excp
    end
  end
  it "To check tour is booked for same building on same contact" , :"817" => true do
    puts "C817 : To check tour is booked for same building on same contact"
    begin
      account = Salesforce.createRecords(@salesforceBulk,"Account",@testData['Account'])
      puts "\n"
      puts "Checking account insertion..."
      expect(account[0]['Id']).to_not eql nil
      puts "Account created successfully"
      payloadHash = JSON.parse(@testRailUtility.getPayloadsFromSteps(@testRailUtility.getCase(817)['custom_steps_separated'])[0]['expected'])
      payloadHash['body']['email'] = "test_HP#{rand(900000)}@example.com"
      buildingTestData = @testData['Building']
      buildingTestData[0]['uuid__c'] = SecureRandom.uuid
      payloadHash['body']['buildings_interested_uuids'][0] = Salesforce.getRecords(@salesforceBulk,"Building__c","SELECT UUID__c FROM Building__c WHERE id = '#{Salesforce.createRecords(@salesforceBulk,"Building__c",@testData['Building'])[0]['Id']}'",nil).result.records[0].fetch('UUID__c')

      createdAccount = Salesforce.getRecords(@salesforceBulk,"Account","SELECT UUID__c,Number_Of_Open_Opportunities__c FROM Account WHERE id = '#{account[0]['Id']}'",nil).result.records[0]
      payloadHash['body']['account_uuid'] = createdAccount.fetch('UUID__c')
      payloadHash['body']['tour_building_uuid'] = Salesforce.getRecords(@salesforceBulk,"Building__c","SELECT UUID__c FROM Building__c WHERE name = 'LA-Santa Monica'",nil).result.records[0]
      getResponse = @objSFRest.postData(''+payloadHash.to_json,"#{@testData['ServiceUrls'][0]['tour']}",)
      puts "\n"
      sleep(@timeSettingMap['Sleep']['Environment']['Classic'])
      puts "Checking service call response..."
      expect(getResponse['success']).to be true
      expect(getResponse['result']).to_not eql nil
      Salesforce.addRecordsToDelete('Tour',getResponse['result'].delete('"'))
      getResponse2 = @objSFRest.postData(''+payloadHash.to_json,"#{@testData['ServiceUrls'][0]['tour']}")
      puts "\n"
      puts "Checking service call response..."
      expect(getResponse2['success']).to be true
      expect(getResponse2['result']).to_not eql nil
      Salesforce.addRecordsToDelete('Tour',getResponse2['result'].delete('"'))
      puts "Service call response is #{getResponse2['success']}"
      puts "\n"
      puts "Checking contact creation for given account uuid..."
      createdContact = Salesforce.getRecords(@salesforceBulk,"Contact","SELECT id,Account.Name FROM Contact WHERE Account.id = '#{account[0]['Id']}'",nil).result.records[0]
      expect(createdContact.fetch('Id')).to_not eql nil
      expect(createdContact.fetch('Account.Name')).to eql @testData['Account'][0]['Name']
      puts "Contact created successfully"
      puts "\n"
      if createdAccount.fetch('Number_Of_Open_Opportunities__c').eql?('0') then
        puts "Checking opportunity creation..."
        createdOpportunity = Salesforce.getRecords(@salesforceBulk,"Opportunity","SELECT id,Locations_Interested__c FROM Opportunity WHERE Account.id = '#{account[0]['Id']}'",nil).result.records[0]
        expect(createdOpportunity.fetch('Id')).to_not eql nil
        Salesforce.addRecordsToDelete('Opportunity',createdOpportunity.fetch('Id'))
        puts "Opportunity created successfully"
        puts "\n"
        puts "Checking open activities..."
        expect(Salesforce.getRecords(@salesforceBulk,'Task',"SELECT id FROM Task WHERE WhatId = '#{getResponse['result'].delete('"')}'",nil).result.records[0].fetch('Id')).to_not eql nil
        puts "Open activities created successfully"
        puts "\n"
      end
      puts "\n"
      puts "Checking open activities..."
      expect(Salesforce.getRecords(@salesforceBulk,'Task',"SELECT id FROM Task WHERE WhatId = '#{getResponse2['result'].delete('"')}'",nil).result.records[0].fetch('Id')).to_not eql nil
      puts "Open activities created successfully"
      puts "\n"
      @testRailUtility.postResult(817,"Result for case 817 is #{getResponse['success']}",1,@runId)
    rescue Exception => excp
      @testRailUtility.postResult(817,"Result for case 817 is #{excp}",5,@runId)
      raise excp
    end
  end

  it "To check tour is created and it is Booked by the contact which is provided in payload" , :"833" => true do
    puts "C833: To check tour is created and it is Booked by the contact which is provided in payload"
    begin
      payloadHash = JSON.parse(@testRailUtility.getPayloadsFromSteps(@testRailUtility.getCase(833)['custom_steps_separated'])[0]['expected'])
      payloadHash['body']['email'] = "test_HP#{rand(900000)}@example.com"
      buildingTestData = @testData['Building']
      buildingTestData[0]['uuid__c'] = SecureRandom.uuid
      payloadHash['body']['buildings_interested_uuids'][0] = Salesforce.getRecords(@salesforceBulk,"Building__c","SELECT UUID__c FROM Building__c WHERE id = '#{Salesforce.createRecords(@salesforceBulk,"Building__c",@testData['Building'])[0]['Id']}'",nil).result.records[0].fetch('UUID__c')

      account = Salesforce.createRecords(@salesforceBulk,"Account",@testData['Account'])
      puts "\n"
      puts "Checking account insertion..."
      expect(account[0]['Id']).to_not eql nil
      puts "Account created successfully"
      contact = @testData['Contact']
      contact[0]['accountId'] = account[0]['Id']
      contact[0]['email'] = "test_enzi#{rand(900000)}@example.com"
      puts contact
      primaryMember = Salesforce.createRecords(@salesforceBulk,"Contact",contact)
      createdAccount = Salesforce.getRecords(@salesforceBulk,"Account","SELECT UUID__c FROM Account WHERE id = '#{account[0]['Id']}'",nil).result.records[0]
      payloadHash['body']['account_uuid'] = createdAccount.fetch('UUID__c')
      payloadHash['body']['booked_by_contact_id'] = primaryMember[0]['Id']
      getResponse = @objSFRest.postData(''+payloadHash.to_json,"#{@testData['ServiceUrls'][0]['tour']}")
      puts "\n"
      sleep(@timeSettingMap['Sleep']['Environment']['Classic'])
      puts "Checking service call response..."
      expect(getResponse['success']).to be true
      expect(getResponse['result']).to_not eql nil
      Salesforce.addRecordsToDelete('Tour',getResponse['result'].delete('"'))
      puts "Service call response is #{getResponse['success']}"
      puts "\n"
      puts "Checking Booked by contact id on tour..."
      puts Salesforce.getRecords(@salesforceBulk,"Tour_Outcome__c","SELECT Booked_by_contact_id__c FROM Tour_Outcome__c WHERE id = '#{getResponse['result'].delete('"')}'",nil).result.records.inspect
      puts primaryMember[0]['Id']
      expect(Salesforce.getRecords(@salesforceBulk,"Tour_Outcome__c","SELECT Booked_by_contact_id__c FROM Tour_Outcome__c WHERE id = '#{getResponse['result'].delete('"')}'",nil).result.records[0].fetch('booked_by_contact_id__c')).to eql primaryMember[0]['Id']
      puts "Booked by contact id checked successfully"
      puts "\n"
      puts "Checking open activities..."
      expect(Salesforce.getRecords(@salesforceBulk,'Task',"SELECT id FROM Task WHERE WhatId = '#{getResponse['result'].delete('"')}'",nil).result.records[0].fetch('Id')).to_not eql nil
      puts "Open activities created successfully"
      puts "\n"
      @testRailUtility.postResult(833,"Result for case 833 is #{getResponse['success']}",1,@runId)
    rescue Exception => excp
      @testRailUtility.postResult(833,"Result for case 833 is #{excp}",5,@runId)
      raise excp
    end
  end
  it "To check tour is created for a journey, whose UUID is passed in payload" ,:"842" => true do
    puts "C842 : To check tour is created for a journey, whose UUID is passed in payload"
    begin
      payloadHash = JSON.parse(@testRailUtility.getPayloadsFromSteps(@testRailUtility.getCase(842)['custom_steps_separated'])[0]['expected'])
      payloadHash['body']['email'] = "test_HP#{rand(900000)}@example.com"
      buildingTestData = @testData['Building']
      buildingTestData[0]['uuid__c'] = SecureRandom.uuid
      payloadHash['body']['buildings_interested_uuids'][0] = Salesforce.getRecords(@salesforceBulk,"Building__c","SELECT UUID__c FROM Building__c WHERE id = '#{Salesforce.createRecords(@salesforceBulk,"Building__c",@testData['Building'])[0]['Id']}'",nil).result.records[0].fetch('UUID__c')

      account = Salesforce.createRecords(@salesforceBulk,"Account",[{"Name":"test_HCL_Bandra#{rand(10)}"}])
      puts "\n"
      puts "Checking account insertion..."
      expect(account[0]['Id']).to_not eql nil
      puts "Account created successfully"
      contact = @testData['Contact']
      contact[0]['accountId'] = account[0]['Id']
      contact[0]['email'] = "test_enzi#{rand(900000)}@example.com"
      contactId = Salesforce.createRecords(@salesforceBulk,"Contact",contact)
      journey = @testData['Journey']
      journey[0]['Primary_Contact__c'] = contactId[0]['Id']
      journey[0]['NMD_Next_Contact_Date__c'] = Date.today.to_s
      puts journey.inspect
      journeyId = Salesforce.createRecords(@salesforceBulk,"Journey__c",journey)
      createdAccount = Salesforce.getRecords(@salesforceBulk,"Account","SELECT UUID__c FROM Account WHERE id = '#{account[0]['Id']}'",nil).result.records[0]
      Salesforce.addRecordsToDelete('JourneyUUID',Salesforce.getRecords(@salesforceBulk,"Journey__c","SELECT UUID__c FROM Journey__c WHERE id = '#{journeyId[0]['Id']}'",nil).result.records[0].fetch('UUID__c'))
      payloadHash['body']['sf_journey_uuid'] = Salesforce.class_variable_get(:@@createdRecordsIds)['JourneyUUID'][0]['Id']
      payloadHash['body']['account_uuid'] = createdAccount.fetch('UUID__c')
      getResponse = @objSFRest.postData(''+payloadHash.to_json,"#{@testData['ServiceUrls'][0]['tour']}")
      puts "\n"
      sleep(@timeSettingMap['Sleep']['Environment']['Classic'])
      puts "Checking service call response..."
      expect(getResponse['success']).to be true
      expect(getResponse['result']).to_not eql nil
      Salesforce.addRecordsToDelete('Tour',getResponse['result'].delete('"'))
      puts "Service call response is #{getResponse['success']}"
      puts "\n"
      puts "Checking Journey on tour..."
      bookedTour = Salesforce.getRecords(@salesforceBulk,"Tour_Outcome__c","SELECT id,UUID__c,Status__c ,Journey__c,Journey__r.Status__c FROM Tour_Outcome__c WHERE id = '#{getResponse['result'].delete('"')}'",nil).result.records[0]
      expect(bookedTour.fetch('Journey__c')).to eql journeyId[0]['Id']
      puts "Journey checked successfully"
      puts "\n"
      Salesforce.addRecordsToDelete('TourUUID',bookedTour.fetch('uuid__c'))
      puts "Checking status on tour"
      expect(bookedTour.fetch('Status__c')).to eql "Scheduled"
      puts "Satus of tour is :: #{bookedTour.fetch('Status__c')}"
      puts "\n"
      puts "Checking status of booked tour"
      expect(bookedTour.fetch('Journey__r.Status__c')).to eql "Completed"
      puts "Status of tour is :: #{bookedTour.fetch('Journey__r.Status__c')}"
      puts "Status of tour checked successfully"
      puts "Checking open activities..."
      expect(Salesforce.getRecords(@salesforceBulk,'Task',"SELECT id FROM Task WHERE WhatId = '#{getResponse['result'].delete('"')}'",nil).result.records[0].fetch('Id')).to_not eql nil
      puts "Open activities created successfully"
      puts "\n"
      @testRailUtility.postResult(842,"Result for case 842 is #{getResponse['success']}",1,@runId)
    rescue Exception => excp
      @testRailUtility.postResult(842,"Result for case 842 is #{excp}",5,@runId)
      raise excp
    end
  end

  it "To check tour is created for completed journey whose UUID is passed in payload" , :"847" => true do
    puts "C847 : To check tour is created for completed journey whose UUID is passed in payload"
    begin
      payloadHash = JSON.parse(@testRailUtility.getPayloadsFromSteps(@testRailUtility.getCase(847)['custom_steps_separated'])[0]['expected'])
      payloadHash['body']['email'] = "test_HP#{rand(900000)}@example.com"
      buildingTestData = @testData['Building']
      buildingTestData[0]['uuid__c'] = SecureRandom.uuid
      payloadHash['body']['buildings_interested_uuids'][0] = Salesforce.getRecords(@salesforceBulk,"Building__c","SELECT UUID__c FROM Building__c WHERE id = '#{Salesforce.createRecords(@salesforceBulk,"Building__c",@testData['Building'])[0]['Id']}'",nil).result.records[0].fetch('UUID__c')

      payloadHash['body']['sf_journey_uuid'] = Salesforce.class_variable_get(:@@createdRecordsIds)['JourneyUUID'][0]['Id']
      getResponse = @objSFRest.postData(''+payloadHash.to_json,"#{@testData['ServiceUrls'][0]['tour']}")
      puts "\n"
      sleep(@timeSettingMap['Sleep']['Environment']['Classic'])
      puts "Checking service call response..."
      expect(getResponse['success']).to be true
      expect(getResponse['result']).to_not eql nil
      Salesforce.addRecordsToDelete('Tour',getResponse['result'].delete('"'))
      puts "Service call response is #{getResponse['success']}"
      puts "\n"
      puts "Checking Journey on tour..."
      bookedTour = Salesforce.getRecords(@salesforceBulk,"Tour_Outcome__c","SELECT UUID__c,Status__c ,Journey__r.uuid__c FROM Tour_Outcome__c WHERE id = '#{getResponse['result'].delete('"')}'",nil).result.records[0]
      puts bookedTour.inspect
      expect(bookedTour.fetch('Journey__r.UUID__c')).to eql payloadHash['body']['sf_journey_uuid']
      puts "Journey checked successfully"
      puts "\n"
      puts "Checking open activities..."
      expect(Salesforce.getRecords(@salesforceBulk,'Task',"SELECT id FROM Task WHERE WhatId = '#{getResponse['result'].delete('"')}'",nil).result.records[0].fetch('Id')).to_not eql nil
      puts "Open activities created successfully"
      puts "\n"
      @testRailUtility.postResult(847,"Result for case 847 is #{getResponse['success']}",1,@runId)
    rescue Exception => excp
      @testRailUtility.postResult(847,"Result for case 847 is #{excp}",5,@runId)
      raise excp
    end
  end
  #
  #Dependent on above example, Because the booked tour in above example is used below.
  #
  it "To check tour is created and it is associated with original tour whose UUID is passed in payload" , :"851" => true do
    puts "C851 : To check tour is created and it is associated with original tour whose UUID is passed in payload"
    begin
      payloadHash = JSON.parse(@testRailUtility.getPayloadsFromSteps(@testRailUtility.getCase(851)['custom_steps_separated'])[0]['expected'])
      payloadHash['body']['email'] = "test_HP#{rand(900000)}@example.com"
      buildingTestData = @testData['Building']
      buildingTestData[0]['uuid__c'] = SecureRandom.uuid
      payloadHash['body']['buildings_interested_uuids'][0] = Salesforce.getRecords(@salesforceBulk,"Building__c","SELECT UUID__c FROM Building__c WHERE id = '#{Salesforce.createRecords(@salesforceBulk,"Building__c",@testData['Building'])[0]['Id']}'",nil).result.records[0].fetch('UUID__c')

      payloadHash['body']['original_tour_uuid'] = Salesforce.class_variable_get(:@@createdRecordsIds)['TourUUID'][0]['Id']
      getResponse = @objSFRest.postData(''+payloadHash.to_json,"#{@testData['ServiceUrls'][0]['tour']}")
      puts "\n"
      sleep(@timeSettingMap['Sleep']['Environment']['Classic'])
      puts "Checking service call response..."
      expect(getResponse['success']).to be true
      expect(getResponse['result']).to_not eql nil
      Salesforce.addRecordsToDelete('Tour',getResponse['result'].delete('"'))
      puts "Service call response is #{getResponse['success']}"
      puts "\n"
      puts "Checking Original Tour on tour..."
      bookedTour = Salesforce.getRecords(@salesforceBulk,"Tour_Outcome__c","SELECT Original_Tour__r.Id FROM Tour_Outcome__c WHERE id = '#{getResponse['result'].delete('"')}'",nil).result.records[0]
      expect(bookedTour.fetch('Original_Tour__r.Id')).to eql Salesforce.class_variable_get(:@@createdRecordsIds)['Tour'][0]["#{Salesforce.class_variable_get(:@@createdRecordsIds)['Tour']}"]
      puts "Original Tour is :: #{bookedTour.fetch('Original_Tour__r.id')}"
      puts "Original Tour checked successfully"
      @testRailUtility.postResult(851,"Result for case 851 is #{getResponse['success']}",1,@runId)
    rescue Exception => excp
      @testRailUtility.postResult(851,"Result for case 851 is #{excp}",5,@runId)
      raise excp
    end
  end
  after(:each){
    puts "\n"
    puts "---------------------------------------------------------------------------------------------------------------------------"
  }

  after(:all){

    allRecordIds = Salesforce.class_variable_get(:@@createdRecordsIds)
    puts "Created data to be deleted :: #{allRecordIds}"
    Salesforce.deleteRecords(@salesforceBulk,"Journey__c",allRecordIds['Journey__c'])
    Salesforce.deleteRecords(@salesforceBulk,"Tour_Outcome__c",allRecordIds['Tour_Outcome__c'])
    Salesforce.deleteRecords(@salesforceBulk,"Tour_Outcome__c",allRecordIds['Tour'])
    Salesforce.deleteRecords(@salesforceBulk,"Opportunity",allRecordIds['Opportunity'])
    Salesforce.deleteRecords(@salesforceBulk,"Account",allRecordIds['Account'])
    Salesforce.deleteRecords(@salesforceBulk,"Contact",allRecordIds['Contact'])


  }
end
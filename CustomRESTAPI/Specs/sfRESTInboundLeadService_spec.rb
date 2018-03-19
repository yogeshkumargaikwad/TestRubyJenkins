#Created By : Monika Pingale
#Created Date : 18th Jan 2018
#Purpose: This class contains specs related to salesforce rest web service
#Modified date :
require "rspec"
require 'salesforce'
require 'securerandom'
#require_relative "helper.rb"
require_relative File.expand_path(Dir.pwd+"/CustomRESTAPI/PageObjects/sfRESTService.rb")
require_relative File.expand_path("GemUtilities/EnziTestRailUtility/lib/EnziTestRailUtility.rb")
describe SfRESTService do

	before(:all){
		#{"grant_type"=>@@credentails['QAAuto']['grant_type'],"client_id"=>@@credentails['QAAuto']['client_id'],"client_secret"=>@@credentails['QAAuto']['client_secret'], "username"=>@@credentails['QAAuto']['username'],"password"=>"#{@@credentails['QAAuto']['password']}"}
		@executionResult =  RSpec::Core::Example::ExecutionResult.new
		testDataFile = File.open(File.expand_path(Dir.pwd+"/CustomRESTAPI/TestData/testData.json"), "r")
		testDataInJson = testDataFile.read()
		@testData = JSON.parse(testDataInJson)
		@salesforceBulk = ARGV[1]
		#@salesforceBulk = Salesforce.login(SfRESTService.class_variable_get(:@@credentails)['QAAuto']['username'],SfRESTService.class_variable_get(:@@credentails)['QAAuto']['password'],true)
		config = YAML.load_file('credentials.yaml')
		profileAndSandBoxType = ARGV[0].split(',')
		@objSFRest = SfRESTService.new(config[profileAndSandBoxType[0]][profileAndSandBoxType[1]]['grant_type'],config[profileAndSandBoxType[0]][profileAndSandBoxType[1]]['client_id'],config[profileAndSandBoxType[0]][profileAndSandBoxType[1]]['client_secret'],config[profileAndSandBoxType[0]][profileAndSandBoxType[1]]['username'],config[profileAndSandBoxType[0]][profileAndSandBoxType[1]]['password'])
		@testRailUtility = EnziTestRailUtility::TestRailUtility.new(config['TestRail']['username'],config['TestRail']['password'])
		@timeSettingMap = YAML.load_file(Dir.pwd+'/timeSettings.yaml')
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
      @runId = @testRailUtility.addRun("RESTAPI Inbound lead Service",4,26,arrCaseIds)['id']
    else
      @runId = ENV['RUN_ID']
    end
    if ENV['RUN_ID'].nil? then
      @runId = @testRailUtility.addRun("RESTAPI Inbound lead Service",4,26,arrCaseIds)['id']
    end
=end
    @runId = ENV['RUN_ID']
	}

	before(:each){
		puts "\n"
		puts "---------------------------------------------------------------------------------------------------------------------------"
	}

	it "C363: To check lead is created when only required values are provided in payload" , :"363" => true  do
		puts "\n"
		puts "C363: To check lead is created when only required values are provided in payload"
		begin
			payloadHash = JSON.parse(@testRailUtility.getPayloadsFromSteps(@testRailUtility.getCase(363)['custom_steps_separated'])[0]['expected'])
			payloadHash['body']['email'] = "test_Bond#{rand(900000)}@example.com"
			buildingTestData = @testData['Building']
			buildingTestData[0]['uuid__c'] = SecureRandom.uuid
			payloadHash['body']['buildings_interested_uuids'][0] = Salesforce.getRecords(@salesforceBulk,"Building__c","SELECT UUID__c FROM Building__c WHERE id = '#{Salesforce.createRecords(@salesforceBulk,"Building__c",@testData['Building'])[0]['Id']}'",nil).result.records[0].fetch('UUID__c')
			getResponse = @objSFRest.postData(''+payloadHash.to_json,"#{@testData['ServiceUrls'][1]['inboundLead']}")
			puts "\n"
			sleep(@timeSettingMap['Sleep']['Environment']['Lightening']['Max'])
			puts "Checking service call response..."
			expect(getResponse['success']).to be true
			expect(getResponse['lead_sfid']).to_not eql nil
			Salesforce.addRecordsToDelete('Lead',getResponse['lead_sfid'])
			puts "Service call response is #{getResponse['success']}"
			createdLead = Salesforce.getRecords(@salesforceBulk,"Lead","SELECT id,Status,RecordType.Name,Type__c,Email_Quality__c,Has_Active_Journey__c FROM Lead WHERE email = '#{payloadHash['body']['email']}'",nil).result.records[0]
			puts "\n"
			puts "Checking status field on lead..."
			expect(createdLead.fetch('Status')).to eql 'Open'
			puts "Status is :: #{createdLead.fetch('Status')}"
			puts "Status checked successfully"
			puts "\n"
			puts "Checking record type field on lead..."
			expect(createdLead.fetch('RecordType.Name')).to eql 'Consumer'
			puts "Record type is :: #{createdLead.fetch('RecordType.Name')}"
			puts "Record type checked successfully"
			puts "\n"
			puts "Checking type of building interest field on lead..."
			expect(createdLead.fetch('Type__c')).to eql 'Office Space'
			puts "Type of building interest is :: #{createdLead.fetch('Type__c')}"
			puts "Type of building interest checked successfully"
			puts "\n"
			puts "Checking email quality field on lead..."
			expect(createdLead.fetch('Email_Quality__c')).to eql 'Pending'
			puts "Email quality is :: #{createdLead.fetch('Email_Quality__c')}"
			puts "Email quality checked successfully"
			puts "\n"
			puts "Checking journey creation..."
			createdJourney = Salesforce.getRecords(@salesforceBulk,"Journey__c","SELECT id FROM Journey__c WHERE email__c = '#{payloadHash['body']['email']}'",nil).result.records[0].fetch('Id')
			expect(createdJourney).to_not eql nil
			Salesforce.addRecordsToDelete('Journey__c',createdJourney)
			puts "Journey created successfully"
			puts "\n"
			puts "Checking active journey on lead..."
			expect(createdLead.fetch('Has_Active_Journey__c').eql?('true')).to be true
			puts "Active journey is :: #{createdLead.fetch('Has_Active_Journey__c')}"
			puts "Active journey checked successfully"
			puts "\n"
			puts "Checking open activities..."
			expect(Salesforce.getRecords(@salesforceBulk,'Task',"SELECT id FROM Task WHERE WhoId = '#{getResponse['lead_sfid']}'",nil).result.records[0].fetch('Id')).to_not eql nil
			puts "Open activities created successfully"
			@testRailUtility.postResult(363,"Result for case 363 is #{getResponse['success']}",1,@runId)
		rescue Exception => excp
			@testRailUtility.postResult(363,"Result for case 363 is #{excp}",5,@runId)
			raise excp
		end
	end

	it "To check lead is created when only required values are provided in payload" , :"364" => true do
		puts "\n"
		puts "C364 : To check lead is created when only required values are provided in payload"
		begin
			payloadHash = JSON.parse(@testRailUtility.getPayloadsFromSteps(@testRailUtility.getCase(364)['custom_steps_separated'])[0]['expected'])
			payloadHash['body']['email'] = "test_Bond#{rand(900000)}@example.com"
			payloadHash['body']['buildings_interested_uuids'][0] = Salesforce.getRecords(@salesforceBulk,"Building__c","SELECT UUID__c FROM Building__c WHERE id = '#{Salesforce.class_variable_get(:@@createdRecordsIds)['Building__c'][0]['Id']}'").result.records[0].fetch('UUID__c')
			getResponse = @objSFRest.postData(''+payloadHash.to_json,"#{@testData['ServiceUrls'][1]['inboundLead']}")
			puts "\n"
			sleep(@timeSettingMap['Sleep']['Environment']['Lightening']['Max'])
			puts "Checking service call response..."
			expect(getResponse['success']).to be true
			expect(getResponse['lead_sfid']).to_not  eql nil
			Salesforce.addRecordsToDelete('Lead',getResponse['lead_sfid'])
			puts "Service call response is #{getResponse['success']}"
			puts "\n"
			createdLead = Salesforce.getRecords(@salesforceBulk,"Lead","SELECT id,Status,RecordType.Name,Type__c,Email_Quality__c FROM Lead WHERE email = '#{payloadHash['body']['email']}'",nil).result.records[0]
			puts "Checking status field on lead..."
			expect(createdLead.fetch('Status')).to eql 'Open'
			puts "Status is :: #{createdLead.fetch('Status')}"
			puts "Status checked successfully"
			puts "\n"
			puts "Checking record type field on lead..."
			expect(createdLead.fetch('RecordType.Name')).to eql 'Consumer'
			puts "Record type is :: #{createdLead.fetch('RecordType.Name')}"
			puts "Record type checked successfully"
			puts "\n"
			puts "Checking type of building interest field on lead..."
			expect(createdLead.fetch('Type__c')).to eql 'Office Space'
			puts "Type of building interest is :: #{createdLead.fetch('Type__c')}"
			puts "Type of building interest checked successfully"
			puts "\n"
			puts "Checking email quality field on lead..."
			expect(createdLead.fetch('Email_Quality__c')).to eql 'Pending'
			puts "Email quality is :: #{createdLead.fetch('Email_Quality__c')}"
			puts "Email quality checked successfully"
			puts "\n"
			puts "Checking open activities..."
			expect(Salesforce.getRecords(@salesforceBulk,'Task',"SELECT id FROM Task WHERE WhoId = '#{getResponse['lead_sfid']}'",nil).result.records[0].fetch('Id')).to_not eql nil
			puts "Open activities created successfully"
			@testRailUtility.postResult(364,"Result for case 364 is #{getResponse['success']}",1,@runId)
		rescue Exception => excp
			@testRailUtility.postResult(364,"Result for case 364 is #{excp}",5,@runId)
			raise excp
		end
	end

	it "to check lead is created without lead source and lead source detail" , :"365" => true do
		puts "\n"
		puts "C365: To check lead is created without lead source and lead source detail"
		begin
			payloadHash = JSON.parse(@testRailUtility.getPayloadsFromSteps(@testRailUtility.getCase(365)['custom_steps_separated'])[0]['expected'])
			payloadHash['body']['email'] = "test_Bond#{rand(900000)}@example.com"
			payloadHash['body']['buildings_interested_uuids'][0] = Salesforce.getRecords(@salesforceBulk,"Building__c","SELECT UUID__c FROM Building__c WHERE id = '#{Salesforce.class_variable_get(:@@createdRecordsIds)['Building__c'][0]['Id']}'").result.records[0].fetch('UUID__c')
			getResponse = @objSFRest.postData(''+payloadHash.to_json,"#{@testData['ServiceUrls'][1]['inboundLead']}")
			puts "\n"
			sleep(@timeSettingMap['Sleep']['Environment']['Lightening']['Max'])
			puts "Checking service call response..."
			expect(getResponse['success']).to be true
			expect(getResponse['lead_sfid']).to_not  eql nil
			Salesforce.addRecordsToDelete('Lead',getResponse['lead_sfid'])
			puts "Service call response is #{getResponse['success']}"
			puts "\n"
			createdLead = Salesforce.getRecords(@salesforceBulk,"Lead","SELECT id,Status,RecordType.Name,Type__c,Email_Quality__c,Has_Active_Journey__c FROM Lead WHERE email = '#{payloadHash['body']['email']}'",nil).result.records[0]
			puts "Checking status field on lead..."
			expect(createdLead.fetch('Status')).to eql 'Open'
			puts "Status is :: #{createdLead.fetch('Status')}"
			puts "Status checked successfully"
			puts "\n"
			puts "Checking record type field on lead..."
			expect(createdLead.fetch('RecordType.Name')).to eql 'Consumer'
			puts "Record type is :: #{createdLead.fetch('RecordType.Name')}"
			puts "Record type checked successfully"
			puts "\n"
			puts "Checking type of building interest field on lead..."
			expect(createdLead.fetch('Type__c')).to eql 'Office Space'
			puts "Type of building interest is :: #{createdLead.fetch('Type__c')}"
			puts "Type of building interest checked successfully"
			puts "\n"
			puts "Checking email quality field on lead..."
			expect(createdLead.fetch('Email_Quality__c')).to eql 'Pending'
			puts "Email quality is :: #{createdLead.fetch('Email_Quality__c')}"
			puts "Email quality checked successfully"
			puts "\n"
			puts "Checking active journey on lead..."
			expect(createdLead.fetch('Has_Active_Journey__c').eql?('false')).to be true
			puts "Active journey is :: #{createdLead.fetch('Has_Active_Journey__c')}"
			puts "Active journey checked successfully"
			puts "\n"
			sleep(@timeSettingMap['Sleep']['Environment']['Lightening']['Max'])
			puts "Checking open activities..."
			puts Salesforce.getRecords(@salesforceBulk,'Task',"SELECT id FROM Task WHERE WhoId = '#{getResponse['lead_sfid']}'",nil).result.inspect
			expect(Salesforce.getRecords(@salesforceBulk,'Task',"SELECT id FROM Task WHERE WhoId = '#{getResponse['lead_sfid']}'",nil).result.records[0].fetch('Id')).to_not eql nil
			puts "Open activities created successfully"
			@testRailUtility.postResult(365,"Result for case 365 is #{getResponse['success']}",1,@runId)
		rescue Exception => excp
			@testRailUtility.postResult(365,"Result for case 365 is #{excp}",5,@runId)
			raise excp
		end
	end

	it "To check lead is created when contact referrer_only_field is true and referrer_sfid is provided in payload" , :"366" => true do
		puts "\n"
		puts "C366 : To check lead is created when contact referrer_only_field is true and referrer_sfid is provided in payload"
		begin
			account = Salesforce.createRecords(@salesforceBulk,"Account",@testData['Account'])
			puts "\n"
			puts "Checking account insertion..."
			expect(account[0]['Id']).to_not eql nil
			puts "Account created successfully"
			contact = @testData['Contact']
			contact[0]['email'] = "test_Enzigma#{rand(900000)}@example.com"
			contact[0]['accountId'] = account[0]['Id']
			referrer = Salesforce.createRecords(@salesforceBulk,"Contact",contact)
			payloadHash = JSON.parse(@testRailUtility.getPayloadsFromSteps(@testRailUtility.getCase(366)['custom_steps_separated'])[0]['expected'])
			payloadHash['body']['referrer_sfid'] = referrer[0]['Id']
			payloadHash['body']['email'] = "test_Bond#{rand(900000)}@example.com"
			payloadHash['body']['buildings_interested_uuids'][0] = Salesforce.getRecords(@salesforceBulk,"Building__c","SELECT UUID__c FROM Building__c WHERE id = '#{Salesforce.class_variable_get(:@@createdRecordsIds)['Building__c'][0]['Id']}'").result.records[0].fetch('UUID__c')
			puts "\n"
			puts "Checking contact insertion..."
			expect(referrer[0]['Id']).to_not eql nil
			puts "Contact created successfully"
			getResponse = @objSFRest.postData(''+payloadHash.to_json,"#{@testData['ServiceUrls'][1]['inboundLead']}")
			puts "\n"
			sleep(@timeSettingMap['Sleep']['Environment']['Lightening']['Max'])
			puts "Checking service call response..."
			expect(getResponse['success']).to be true
			expect(getResponse['lead_sfid']).to_not  eql nil
			Salesforce.addRecordsToDelete('Lead',getResponse['lead_sfid'])
			puts "Service call response is #{getResponse['success']}"
			createdLead = Salesforce.getRecords(@salesforceBulk,"Lead","SELECT id,Contact_Broker__c,DoNotCall,HasOptedOutOfEmail,Referral_Company_Name__c,Referrer__c FROM Lead WHERE email = '#{payloadHash['body']['email']}'",nil).result.records[0]
			puts "\n"
			puts createdLead.inspect
			puts "Checking Contact Broker field on lead..."
			expect(createdLead.fetch('Contact_Broker__c').eql?('true') ).to be true
			puts "Contact Broker is :: #{createdLead.fetch('Contact_Broker__c')}"
			puts "Contact Broker field is checked successfully"
			puts "\n"
			puts "Checking DoNotCall field on lead..."
			expect(createdLead.fetch('DoNotCall').eql?('true')).to be true
			puts "DoNotCall is :: #{createdLead.fetch('DoNotCall')}"
			puts "DoNotCall is checked successfully"
			puts "\n"
			puts "Checking HasOptedOutOfEmail field on lead..."
			expect(createdLead.fetch('HasOptedOutOfEmail').eql?('true')).to be true
			puts "HasOptedOutOfEmail is :: #{createdLead.fetch('HasOptedOutOfEmail')}"
			puts "HasOptedOutOfEmail is checked successfully"
			puts "\n"
			puts "Checking Referral Company Name field on lead..."
			expect(createdLead.fetch('Referral_Company_Name__c')).to eql @testData['Account'][0]['Name']
			puts "Referral Company Name is :: #{createdLead.fetch('Referral_Company_Name__c')}"
			puts "Referral Company Name field is checked successfully"
			puts "\n"
			puts "Checking Referrer on lead..."
			expect(createdLead.fetch('Referrer__c')).to eql referrer[0]['Id']
			puts "Referrer is :: #{createdLead.fetch('Referrer__c')}"
			puts "Referrer field is checked successfully"
			@testRailUtility.postResult(366,"Result for case 366 is #{getResponse['success']}",1,@runId)
		rescue Exception => excp
			@testRailUtility.postResult(366,"Result for case 366 is #{excp}",5,@runId)
			raise excp
		end
	end

	it "To check lead is created and it is associated with campaign when campaign_sfid is provided in payload" , :"367" => true do
		puts "\n"
		puts "C367 : To check lead is created and it is associated with campaign when campaign_sfid is provided in payload"
		begin
			campaign = Salesforce.createRecords(@salesforceBulk,"Campaign",@testData['Campaign'])
			payloadHash = JSON.parse(@testRailUtility.getPayloadsFromSteps(@testRailUtility.getCase(367)['custom_steps_separated'])[0]['expected'])
			payloadHash['body']['email'] = "test_Bond#{rand(900000)}@example.com"
			payloadHash['body']['campaign_sfid'] = campaign[0]['Id']
			payloadHash['body']['buildings_interested_uuids'][0] =  Salesforce.getRecords(@salesforceBulk,"Building__c","SELECT UUID__c FROM Building__c WHERE id = '#{Salesforce.class_variable_get(:@@createdRecordsIds)['Building__c'][0]['Id']}'").result.records[0].fetch('UUID__c')
			getResponse = @objSFRest.postData(''+payloadHash.to_json,"#{@testData['ServiceUrls'][1]['inboundLead']}")
			puts "\n"
			sleep(@timeSettingMap['Sleep']['Environment']['Lightening']['Max'])
			puts "Checking service call response..."
			expect(getResponse['success']).to be true
			expect(getResponse['lead_sfid']).to_not eql nil
			Salesforce.addRecordsToDelete('Lead',getResponse['lead_sfid'])
			puts "Service call response is #{getResponse['success']}"
			createdCampaign = Salesforce.getRecords(@salesforceBulk,"CampaignMember","SELECT CampaignID FROM CampaignMember WHERE LeadId = '#{getResponse['lead_sfid']}'",nil).result.records[0]
			puts "\n"
			puts "Checking number open activities..."
			puts Salesforce.getRecords(@salesforceBulk,'Task',"SELECT id FROM Task WHERE WhoId = '#{getResponse['lead_sfid']}'",nil).result.records.size
			expect(Salesforce.getRecords(@salesforceBulk,'Task',"SELECT id FROM Task WHERE WhoId = '#{getResponse['lead_sfid']}'",nil).result.records.size == 1).to be true
			puts "Open activities created successfully"
			puts "\n"
			puts "Checking Campaign on lead..."
			expect(createdCampaign.fetch('CampaignId')).to eql campaign[0]['Id']
			puts "Campaign is :: #{createdCampaign.fetch('CampaignId')}"
			puts "Campaign checked successfully"
			@testRailUtility.postResult(367,"Result for case 367 is #{getResponse['success']}",1,@runId)
		rescue Exception => excp
			@testRailUtility.postResult(367,"Result for case 366 is #{excp}",5,@runId)
			raise excp
		end
	end

	it "To check lead is created when contact referrer_only_field is false and referrer_sfid is provided in payload", :"450" => true do
		puts "\n"
		puts "C450 : To check lead is created when contact referrer_only_field is false and referrer_sfid is provided in payload"
		begin
			account = Salesforce.createRecords(@salesforceBulk,"Account",@testData['Account'])
			puts "\n"
			puts "Checking account insertion..."
			expect(account[0]['Id']).to_not eql nil
			puts "Account created successfully"
			contact = @testData['Contact']
			contact[0]['email'] = "test_Enzigma#{rand(900000)}@example.com"
			contact[0]['accountId'] = account[0]['Id']
			referrer = Salesforce.createRecords(@salesforceBulk,"Contact",contact)
			payloadHash = JSON.parse(@testRailUtility.getPayloadsFromSteps(@testRailUtility.getCase(450)['custom_steps_separated'])[0]['expected'])
			payloadHash['body']['email'] = "test_Bond#{rand(900000)}@example.com"
			payloadHash['body']['referrer_sfid'] = referrer[0]['Id']
			payloadHash['body']['buildings_interested_uuids'][0] = Salesforce.getRecords(@salesforceBulk,"Building__c","SELECT UUID__c FROM Building__c WHERE id = '#{Salesforce.class_variable_get(:@@createdRecordsIds)['Building__c'][0]['Id']}'").result.records[0].fetch('UUID__c')
			getResponse = @objSFRest.postData(''+payloadHash.to_json,"#{@testData['ServiceUrls'][1]['inboundLead']}")
			puts "\n"
			sleep(@timeSettingMap['Sleep']['Environment']['Lightening']['Max'])
			puts "Checking service call response..."
			expect(getResponse['success']).to be true
			expect(getResponse['lead_sfid']).to_not eql nil
			Salesforce.addRecordsToDelete('Lead',getResponse['lead_sfid'])
			puts "Service call response is #{getResponse['success']}"
			createdLead = Salesforce.getRecords(@salesforceBulk,"Lead","SELECT id,Contact_Broker__c,Referral_Company_Name__c,Referrer__c FROM Lead WHERE email = '#{payloadHash['body']['email']}'",nil).result.records[0]
			puts "\n"
			puts "Checking Contact Broker field on lead..."
			expect(createdLead.fetch('Contact_Broker__c').eql?('false')).to be true
			puts "Contact Broker is :: #{createdLead.fetch('Contact_Broker__c')}"
			puts "Contact Broker field is checked successfully"
			puts "\n"
			puts "Checking Referral Company Name field on lead..."
			expect(createdLead.fetch('Referral_Company_Name__c')).to eql @testData['Account'][0]['Name']
			puts "Referral Company Name is :: #{createdLead.fetch('Referral_Company_Name__c')}"
			puts "Referral Company Name field is checked successfully"
			puts "\n"
			puts "Checking Referrer on lead..."
			expect(createdLead.fetch('Referrer__c')).to eql referrer[0]['Id']
			puts "Referrer is :: #{createdLead.fetch('Referrer__c')}"
			puts "Referrer field is checked successfully"
			@testRailUtility.postResult(450,"Result for case 450 is #{getResponse['success']}",1,@runId)
		rescue Exception => excp
			@testRailUtility.postResult(450,"Result for case 450 is #{excp}",5,@runId)
			raise excp
		end
	end

	it "To check duplicate leads creation" , :"727" => true do
		puts "\n"
		puts "C727 : To check duplicate leads creation"
		begin
			payloadHash = JSON.parse(@testRailUtility.getPayloadsFromSteps(@testRailUtility.getCase(727)['custom_steps_separated'])[0]['expected'])
			payloadHash['body']['email'] = "test_Bond#{rand(900000)}@example.com"
			payloadHash['body']['buildings_interested_uuids'][0] = Salesforce.getRecords(@salesforceBulk,"Building__c","SELECT UUID__c FROM Building__c WHERE id = '#{Salesforce.class_variable_get(:@@createdRecordsIds)['Building__c'][0]['Id']}'").result.records[0].fetch('UUID__c')
			getResponse = @objSFRest.postData(''+payloadHash.to_json,"#{@testData['ServiceUrls'][1]['inboundLead']}")
			puts "\n"
			sleep(@timeSettingMap['Sleep']['Environment']['Lightening']['Max'])
			puts "Checking service call response..."
			expect(getResponse['success']).to be true
			expect(getResponse['lead_sfid']).to_not eql nil
			Salesforce.addRecordsToDelete('Lead',getResponse['lead_sfid'])
			puts "Service call response is #{getResponse['success']}"
			getResponse2 = @objSFRest.postData(''+payloadHash.to_json,"#{@testData['ServiceUrls'][1]['inboundLead']}")
			puts "\n"
			puts "Checking number of open activities..."
			puts Salesforce.getRecords(@salesforceBulk,'Task',"SELECT id FROM Task WHERE WhoId = '#{getResponse['lead_sfid']}'",nil).result.inspect
			expect(Salesforce.getRecords(@salesforceBulk,'Task',"SELECT id FROM Task WHERE WhoId = '#{getResponse['lead_sfid']}'",nil).result.records.size > 1).to be true
			puts "Open activities created successfully"
			@testRailUtility.postResult(727,"Result for case 727 is #{getResponse['success']}",1,@runId)
		rescue Exception => excp
			@testRailUtility.postResult(727,"Result for case 727 is #{excp}",5,@runId)
			raise excp
		end
	end

	it "To check journey is created for already existed lead when no other journey associated with that lead" , :"728" => true do
		puts "\n"
		puts "C728 : To check journey is created for already existed lead when no other journey associated with that lead"
		begin
			payloadHash = JSON.parse(@testRailUtility.getPayloadsFromSteps(@testRailUtility.getCase(728)['custom_steps_separated'])[0]['expected'])
			payloadHash['body']['email'] = "test_Bond#{rand(900000)}@example.com"
			payloadHash['body']['buildings_interested_uuids'][0] = Salesforce.getRecords(@salesforceBulk,"Building__c","SELECT UUID__c FROM Building__c WHERE id = '#{Salesforce.class_variable_get(:@@createdRecordsIds)['Building__c'][0]['Id']}'").result.records[0].fetch('UUID__c')
			getResponse = @objSFRest.postData(''+payloadHash.to_json,"#{@testData['ServiceUrls'][1]['inboundLead']}")
			puts "\n"
			sleep(@timeSettingMap['Sleep']['Environment']['Lightening']['Max'])
			puts "Checking service call response..."
			expect(getResponse['success']).to be true
			expect(getResponse['lead_sfid']).to_not eql nil
			Salesforce.addRecordsToDelete('Lead',getResponse['lead_sfid'])
			puts "Service call response is #{getResponse['success']}"
			puts "\n"
			payloadHash2 = JSON.parse(@testRailUtility.getPayloadsFromSteps(@testRailUtility.getCase(728)['custom_steps_separated'])[1]['expected'])
			payloadHash2['body']['email'] = payloadHash['body']['email']
			getResponse2 = @objSFRest.postData(''+payloadHash2.to_json,"#{@testData['ServiceUrls'][1]['inboundLead']}")
			Salesforce.addRecordsToDelete('Lead',getResponse['lead_sfid'])
			puts "Checking journey creation..."
			createdJourney = Salesforce.getRecords(@salesforceBulk,"Journey__c","SELECT id FROM Journey__c WHERE email__c = '#{payloadHash['body']['email']}'",nil).result.records[0].fetch('Id')
			expect(createdJourney).to_not eql nil
			Salesforce.addRecordsToDelete('Journey__c',createdJourney)
			puts "Journey created successfully"
			puts "\n"
			puts "Checking number open activities..."
			puts Salesforce.getRecords(@salesforceBulk,'Task',"SELECT id FROM Task WHERE WhoId = '#{getResponse['lead_sfid']}'",nil).result.inspect
			expect(Salesforce.getRecords(@salesforceBulk,'Task',"SELECT id FROM Task WHERE WhoId = '#{getResponse['lead_sfid']}'",nil).result.records.size == 2).to be true
			puts "Open activities created successfully"

			@testRailUtility.postResult(728,"Result for case 728 is #{getResponse['success']}",1,@runId)
		rescue Exception => excp
			@testRailUtility.postResult(728,"Result for case 728 is #{excp}",5,@runId)
			raise excp
		end
	end

	after(:each){
		puts "\n"
		puts "---------------------------------------------------------------------------------------------------------------------------"
	}

	after(:all){
		allRecordIds = Salesforce.class_variable_get(:@@createdRecordsIds)
		puts "Created data to be deleted :: #{@createdLeadIds}....#{allRecordIds}...#{@createdJourneyIds}"
		Salesforce.deleteRecords(@salesforceBulk,"Journey__c",allRecordIds['Journey__c'])
    Salesforce.deleteRecords(@salesforceBulk,"Opportunity",allRecordIds['Opportunity'])
		Salesforce.deleteRecords(@salesforceBulk,"Lead",allRecordIds['Lead'])
		Salesforce.deleteRecords(@salesforceBulk,"Account",allRecordIds['Account'])
		Salesforce.deleteRecords(@salesforceBulk,"Campaign",allRecordIds['Campaign'])
		Salesforce.deleteRecords(@salesforceBulk,"Building__c",allRecordIds['Building__c'])
	}
end
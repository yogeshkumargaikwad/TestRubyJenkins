#Created By : Kishor Shinde
#Created Date : 19/1/2018
#Modified date :
require_relative '../../src/pageObjects/restAPITestContractEvent.rb'
require "selenium-webdriver"
require "rspec"
require 'date'


describe ContractEvent do
	before(:all){
		puts "-----------------------------------------------------------------------------------------"
		testDataFile = File.open("E:/Projects/SF-QA-Automation/kishor/src/testData/testRecords.json", "r")
		testDataInJson = testDataFile.read()
		@testData = JSON.parse(testDataInJson) 
		@sfRESTService = SfRESTService.new()
		@contractEvent = ContractEvent.new()
		puts "Creating common test data..."
		@recordCreated = @contractEvent.createCommonTestData()

	}

		before(:each){
			puts ""
			puts "-----------------------------------------------------------------------------------------"
		}

		context "ContractEvent-->sent" do
			before(:all){
				}
		      before(:each){
		      	}

=begin			
			it "C:451 To check if the membership_agreement_uuid matched with the existing membership_agreement_uuid while hitting payload then existing opportunity should be updated." do
					contractUUID =  "test@5555"
					@mapOpportunityId = Hash.new
					puts "Created Opportunity"
					#@contractEvent.createOpportunity(stageName = nil, buildingNumber = nil ,contractUUID = nil)
					@opportunity = @contractEvent.createOpportunity("selling",0,contractUUID)
					puts @opportunity
					#puts (@opportunity == nil)
					@mapOpportunityId["opportunity"] = @opportunity
					#puts "Opportunity in HashMap"
					#puts @mapOpportunityId

					#@contractEvent.setUpPayload(opportunity_id = nil,company_uuid = nil,membership_agreement_uuid = nil)
					@getResponse = SfRESTService.postData(''+@contractEvent.setUpPayload(nil,"abcdefghi",contractUUID).to_json,"#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}",false)
					#@getResponse = SfRESTService.postData(''+@contractEvent.setUpPayload(nil,"abcdefghi",@testData['ContractEvent']['Opportunity'][0]['Contract_UUID__c']).to_json,"#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}",false)
					puts "Response-->"
					puts @getResponse
					puts "Checking Success..."
					expect(@getResponse['success']).to be true

					puts "Checking Result..."
					expect(@getResponse['result']).to_not eql nil
					
					id = @getResponse['result'].split(':')[1].chomp('"').delete(' ')
					#puts "get only id from responce"
					#puts id
					updatedOpp = @contractEvent.getOpportunityDetails(id)
					#puts updatedOpp
					puts "Checking Contract Sent Date..."
					expect(updatedOpp[1]).to eq Date.today.to_s

					puts "Checking Contract Stage..."
					expect(updatedOpp[3]).to eq "Contract Sent"

					puts "Checking Opportunity Stage"
					expect(updatedOpp[4]).to eq "Closing"
					
					puts "Checking Total Desks Reserved..." 
					expect(updatedOpp[5]).to eq @testData['ContractEvent']['Reservable__c'][0]['Office_Capacity__c'].to_i

					puts "Checking Total Desks Move Outs..." 
					expect(updatedOpp[6]).to eq @testData['ContractEvent']['Reservable__c'][1]['Office_Capacity__c'].to_i

					puts "Checking Total Desks Reserved(net)..." 
					expect(updatedOpp[7]).to eq (@testData['ContractEvent']['Reservable__c'][0]['Office_Capacity__c'].to_i - @testData['ContractEvent']['Reservable__c'][1]['Office_Capacity__c'].to_i)
			end


			it "C:452 To check if opportunity id in the payload is matched with the oppportunity_id in the system after hitting payload then existing opportunity in the system will be updated." do
					contractUUID = "test@123451"
					@mapOpportunityId = Hash.new
					puts "Created Opportunity"
					#@contractEvent.createOpportunity(stageName = nil, buildingNumber = nil ,contractUUID = nil)
					@opportunity = @contractEvent.createOpportunity("selling",0,nil)
					puts @opportunity

					@mapOpportunityId["opportunity"] = @opportunity
					
					@getResponse = SfRESTService.postData(''+@contractEvent.setUpPayload(@opportunity[0].fetch("Id"),"abcdefghijklm",contractUUID).to_json,"#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}",false)
					puts "Response-->"
					puts @getResponse

					puts "Checking Success..."
					expect(@getResponse['success']).to be true

					puts "Checking Result..."
					expect(@getResponse['result']).to_not eql nil
					id = @getResponse['result'].split(':')[1].chomp('"').delete(' ')
					updatedOpp = @contractEvent.getOpportunityDetails(id)
					#puts updatedOpp

					puts "Checking Contract Sent Date..."
					expect(updatedOpp[1]).to eq Date.today.to_s

					puts "Checking Contract Stage..."
					expect(updatedOpp[3]).to eq "Contract Sent"

					puts "Checking Opportunity Stage"
					expect(updatedOpp[4]).to eq "Closing"

					puts "Checking Total Desks Reserved..." 
					expect(updatedOpp[5]).to eq @testData['ContractEvent']['Reservable__c'][0]['Office_Capacity__c'].to_i

					puts "Checking Total Desks Move Outs..." 
					expect(updatedOpp[6]).to eq @testData['ContractEvent']['Reservable__c'][1]['Office_Capacity__c'].to_i

					puts "Checking Total Desks Reserved(net)..." 
					expect(updatedOpp[7]).to eq (@testData['ContractEvent']['Reservable__c'][0]['Office_Capacity__c'].to_i - @testData['ContractEvent']['Reservable__c'][1]['Office_Capacity__c'].to_i)

					puts "Checking Updated Contract UUID..." 
					expect(updatedOpp[8]).to eq contractUUID
			end


			it "C:453 To check if company_uuid in the payload matched with the existing account in the system, there are having open opportunities after hitting payload if building matched with the existing open opportunity then existing opportunity should be updated." do
					contractUUID = "test@123451"
					@mapOpportunityId = Hash.new
					puts "Created Opportunity"
					#@contractEvent.createOpportunity(stageName = nil, buildingNumber = nil ,contractUUID = nil)
					@opportunity1 = @contractEvent.createOpportunity("selling",0,nil)
					@opportunity2 = @contractEvent.createOpportunity("selling",1,nil)
					puts @opportunity1
					puts @opportunity2

					@mapOpportunityId["opportunity"] = @opportunity1
					@mapOpportunityId["opportunity"] << @opportunity2[0]
					#puts "Opportunity in HashMap"
					#puts @mapOpportunityId

					#@contractEvent.setUpPayload(opportunity_id = nil,company_uuid = nil,membership_agreement_uuid = nil)
					@getResponse = SfRESTService.postData(''+@contractEvent.setUpPayload(nil,"#{@testData['ContractEvent']['Account'][0]['UUID__c']}",contractUUID).to_json,"#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}",false)
					puts "Response-->"
					puts @getResponse

					puts "Checking Success..."
					expect(@getResponse['success']).to be true
					puts "Checking Result..."
					expect(@getResponse['result']).to_not eql nil

					id = @getResponse['result'].split(':')[1].chomp('"').delete(' ')
					updatedOpp = @contractEvent.getOpportunityDetails(id)

					puts "Checking oppportunity to be updated"
					expect(id).to eq @opportunity1[0].fetch("Id")
					#puts updatedOpp

					puts "Checking Contract Sent Date..."
					expect(updatedOpp[1]).to eq Date.today.to_s

					puts "Checking Contract Stage..."
					expect(updatedOpp[3]).to eq "Contract Sent"

					puts "Checking Opportunity Stage"
					expect(updatedOpp[4]).to eq "Closing"

					puts "Checking Total Desks Reserved..." 
					expect(updatedOpp[5]).to eq @testData['ContractEvent']['Reservable__c'][0]['Office_Capacity__c'].to_i

					puts "Checking Total Desks Move Outs..." 
					expect(updatedOpp[6]).to eq @testData['ContractEvent']['Reservable__c'][1]['Office_Capacity__c'].to_i

					puts "Checking Total Desks Reserved(net)..." 
					expect(updatedOpp[7]).to eq (@testData['ContractEvent']['Reservable__c'][0]['Office_Capacity__c'].to_i - @testData['ContractEvent']['Reservable__c'][1]['Office_Capacity__c'].to_i)
			end


			it "C:726 To check if company_uuid in the payload matched with the existing account in the system, there are having open opportunities after hitting payload if building does not matched with the existing open opportunity then latest opportunity will be updated." do
					contractUUID = "test@123451"
					@mapOpportunityId = Hash.new
					puts "Created Opportunity"
					#@contractEvent.createOpportunity(stageName = nil, buildingNumber = nil ,contractUUID = nil)
					@opportunity1 = @contractEvent.createOpportunity("selling",1,nil)
					@opportunity2 = @contractEvent.createOpportunity("selling",2,nil)
					puts @opportunity1
					puts @opportunity2

					@mapOpportunityId["opportunity"] = @opportunity1
					@mapOpportunityId["opportunity"] << @opportunity2[0]
					#puts "Opportunity in HashMap"
					#puts @mapOpportunityId

					#@contractEvent.setUpPayload(opportunity_id = nil,company_uuid = nil,membership_agreement_uuid = nil)
					@getResponse = SfRESTService.postData(''+@contractEvent.setUpPayload(nil,"#{@testData['ContractEvent']['Account'][0]['UUID__c']}",contractUUID).to_json,"#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}",false)
					puts "Response-->"
					puts @getResponse

					puts "Checking Success..."
					expect(@getResponse['success']).to be true

					puts "Checking Result..."
					expect(@getResponse['result']).to_not eql nil

					id = @getResponse['result'].split(':')[1].chomp('"').delete(' ')
					updatedOpp = @contractEvent.getOpportunityDetails(id)

					puts "Checking oppportunity to be updated"
					expect(id).to eq @opportunity2[0].fetch("Id")
					#puts updatedOpp

					puts "Checking Contract Sent Date..."
					expect(updatedOpp[1]).to eq Date.today.to_s

					puts "Checking Contract Stage..."
					expect(updatedOpp[3]).to eq "Contract Sent"

					puts "Checking Opportunity Stage"
					expect(updatedOpp[4]).to eq "Closing"

					puts "Checking Total Desks Reserved..." 
					expect(updatedOpp[5]).to eq @testData['ContractEvent']['Reservable__c'][0]['Office_Capacity__c'].to_i

					puts "Checking Total Desks Move Outs..." 
					expect(updatedOpp[6]).to eq @testData['ContractEvent']['Reservable__c'][1]['Office_Capacity__c'].to_i

					puts "Checking Total Desks Reserved(net)..." 
					expect(updatedOpp[7]).to eq (@testData['ContractEvent']['Reservable__c'][0]['Office_Capacity__c'].to_i - @testData['ContractEvent']['Reservable__c'][1]['Office_Capacity__c'].to_i)

					puts "Checking Updated Contract UUID..." 
					expect(updatedOpp[8]).to eq contractUUID
			
			end
=end
			
			it "Scenario 10. To check if company_uuid matched with the existing opportunity and for that account there is having opportunity with the stages closed won or closed lost, while hitting payload for a particular building then new opportunity should be created." do
					membership_agreement_uuid = "test@123451"
					@mapOpportunityId = Hash.new
					puts "Created Opportunity"
					#@contractEvent.createOpportunity(stageName = nil, buildingNumber = nil ,contractUUID = nil)
					@opportunity1 = @contractEvent.createOpportunity("Closed Won",1,"opportunity-1111-1111-opp1")
					@opportunity2 = @contractEvent.createOpportunity("Closed Lost",2,nil)
					puts @opportunity1
					puts @opportunity2

					@mapOpportunityId["opportunity"] = @opportunity1
					@mapOpportunityId["opportunity"] << @opportunity2[0]
					#puts "Opportunity in HashMap"
					#puts @mapOpportunityId

					#@contractEvent.setUpPayload(opportunity_id = nil,company_uuid = nil,membership_agreement_uuid = nil)
					@getResponse = SfRESTService.postData(''+@contractEvent.setUpPayload(nil,"#{@testData['ContractEvent']['Account'][0]['UUID__c']}",membership_agreement_uuid).to_json,"#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}",false)
					puts "Response-->"
					puts @getResponse

					puts "Checking Success..."
					expect(@getResponse['success']).to be true

					puts "Checking Result..."
					expect(@getResponse['result']).to_not eql nil

					id = @getResponse['result'].split(':')[1].chomp('"').delete(' ')

					@mapOpportunityId["opportunity"] << Hash["Id" => id]
					createdOpp = @contractEvent.getOpportunityDetails(id)

					puts "Checking new oppportunity to be Created"
					expect(id).not_to eq nil
					#puts createdOpp

					#puts "Checking Contract Sent Date..."
					#expect(createdOpp[1]).to eq Date.today.to_s

					puts "Checking Contract Stage..."
					expect(createdOpp[3]).to eq "Contract Sent"

					puts "Checking Opportunity Stage"
					expect(createdOpp[4]).to eq "Closing"

					puts "Checking Total Desks Reserved..." 
					expect(createdOpp[5]).to eq @testData['ContractEvent']['Reservable__c'][0]['Office_Capacity__c'].to_i

					puts "Checking Total Desks Move Outs..." 
					expect(createdOpp[6]).to eq @testData['ContractEvent']['Reservable__c'][1]['Office_Capacity__c'].to_i

					puts "Checking Total Desks Reserved(net)..." 
					expect(createdOpp[7]).to eq (@testData['ContractEvent']['Reservable__c'][0]['Office_Capacity__c'].to_i - @testData['ContractEvent']['Reservable__c'][1]['Office_Capacity__c'].to_i)

					puts "Checking Updated Contract UUID..." 
					expect(createdOpp[8]).to eq membership_agreement_uuid

					puts "Checking Close Date"
					d = Date.today
					expect(createdOpp[9]).to eq (d + 30).to_s

			
			end

			it "Scenario 2.  To check membership agreement uuid is not passed while hitting payload then existing opportunity will not be updated." do
					#@contractEvent.setUpPayload(opportunity_id = nil,company_uuid = nil,membership_agreement_uuid = nil)
					@getResponse = SfRESTService.postData(''+@contractEvent.setUpPayload(nil,"#{@testData['ContractEvent']['Account'][0]['UUID__c']}",nil).to_json,"#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}",false)
					puts "Response-->"
					puts @getResponse

					puts "Checking Success..."
					expect(@getResponse['success']).to be false

					puts "Checking Result..."
					expect(@getResponse['result']).to_not eql nil

					result = @getResponse['result']
					puts result
			end

			it "Scenario 11. To check if company_uuid matched with the existing opportunity and for that account there is having opportunity with the stages closed won or closed lost, while hitting payload for a particular building then new opportunity should be created." do
					membership_agreement_uuid = "membership-agreement-uuid-1111"
					@mapOpportunityId = Hash.new
					puts "Created Opportunity"
					#@contractEvent.createOpportunity(stageName = nil, buildingNumber = nil ,contractUUID = nil)
					@opportunity1 = @contractEvent.createOpportunity("Closing",1,"opportunity-1111-1111-opp1","Contract Sent")
					puts @opportunity1

					@mapOpportunityId["opportunity"] = @opportunity1
					
					#@contractEvent.setUpPayload(opportunity_id = nil,company_uuid = nil,membership_agreement_uuid = nil)
					@getResponse = SfRESTService.postData(''+@contractEvent.setUpPayload(nil,"#{@testData['ContractEvent']['Account'][0]['UUID__c']}",membership_agreement_uuid).to_json,"#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}",false)
					puts "Response-->"
					puts @getResponse

					puts "Checking Success..."
					expect(@getResponse['success']).to be true

					puts "Checking Result..."
					expect(@getResponse['result']).to_not eql nil

					id = @getResponse['result'].split(':')[1].chomp('"').delete(' ')

					@mapOpportunityId["opportunity"] << Hash["Id" => id]
					createdOpp = @contractEvent.getOpportunityDetails(id)

					puts "Checking new oppportunity to be Created"
					expect(id).not_to eq nil
					#puts createdOpp

					#puts "Checking Contract Sent Date..."
					#expect(createdOpp[1]).to eq Date.today.to_s

					puts "Checking Contract Stage..."
					expect(createdOpp[3]).to eq "Contract Sent"

					puts "Checking Opportunity Stage"
					expect(createdOpp[4]).to eq "Closing"

					puts "Checking Total Desks Reserved..." 
					expect(createdOpp[5]).to eq @testData['ContractEvent']['Reservable__c'][0]['Office_Capacity__c'].to_i

					puts "Checking Total Desks Move Outs..." 
					expect(createdOpp[6]).to eq @testData['ContractEvent']['Reservable__c'][1]['Office_Capacity__c'].to_i

					puts "Checking Total Desks Reserved(net)..." 
					expect(createdOpp[7]).to eq (@testData['ContractEvent']['Reservable__c'][0]['Office_Capacity__c'].to_i - @testData['ContractEvent']['Reservable__c'][1]['Office_Capacity__c'].to_i)

					puts "Checking Created Contract UUID..." 
					expect(createdOpp[8]).to eq membership_agreement_uuid

					puts "Checking Close Date"
					d = Date.today
					expect(createdOpp[9]).to eq (d + 30).to_s
			end

			
			after(:each){
				if @mapOpportunityId != nil then 
					@contractEvent.deleteCreatedOpportunities(@mapOpportunityId['opportunity'])
				end
				puts "Opportunity Test Data Deleted..."
				}
		end
	after(:all){
		@contractEvent.deleteCreatedRecord()
		puts "Common Test Data Deleted..."
		puts "-----------------------------------------------------------------------------------------"
		}

	after(:each){
		puts ""
		puts "-----------------------------------------------------------------------------------------"
		}

end
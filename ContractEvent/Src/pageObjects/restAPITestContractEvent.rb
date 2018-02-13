#Created By : Kishor Shinde
#Created Date : 19/1/2018
#Modified date :
require_relative File.expand_path('',Dir.pwd)+'/ContractEvent/Src/utilities/sfRESTService.rb'
require 'enziUIUtility'
require 'salesforce'
require 'selenium-webdriver'
require 'yaml'
require 'json'
require 'active_support/core_ext/hash'

class ContractEvent
	@recordToDelete=nil
	@sfBulk=nil
	@sObjectRecords=nil
	@mapCredentials=nil
	@mapRecordType = nil

#read username and password from credentials.yaml file and logged in
#go to home page and then MergeOpportunitiesPage
	def initialize()
		@mapRecordType = Hash.new
		@recordToDelete = Hash.new
		file = File.open(File.expand_path('',Dir.pwd)+"/credentials.yaml", "r")
		@mapCredentials = YAML.load(file.read())
		sObjectRecordsJson = File.read(File.expand_path('',Dir.pwd)+"/ContractEvent/Src/testData/testRecords.json")
		@sObjectRecords = JSON.parse(sObjectRecordsJson)
		@sfBulk = Salesforce.login(@mapCredentials['Staging']['username'],@mapCredentials['Staging']['password'],true)
		recordTypeIds = Salesforce.getRecords(@sfBulk,'RecordType',"Select id,Name from RecordType where SObjectType = 'Account'")

		if recordTypeIds.result.records != nil then
			recordTypeIds.result.records.each do |typeid|
				@mapRecordType.store(typeid[1],typeid[0])
			end
		end
	end

#Create common test data required for all specs
	def createCommonTestData

		accountJSON = @sObjectRecords['ContractEvent']['Account']
		accountJSON[0]["RecordTypeId"] = @mapRecordType["Consumer"]
		accountJSON[1]["RecordTypeId"] = @mapRecordType["Consumer"]
		accountJSON[2]["RecordTypeId"] = @mapRecordType["Mid Market"]
		accountJSON[3]["RecordTypeId"] = @mapRecordType["Enterprise Solutions"]

		#puts "accountJSON"
		#puts accountJSON
		accountId = Salesforce.createRecords(@sfBulk,"Account",accountJSON)
#puts "Account created"
#puts accountId.inspect
		@recordToDelete.store("account",accountId)
#puts accountId[0].fetch("Id")

		contactJSON = @sObjectRecords['ContractEvent']['Contact']
		contactJSON[0]["AccountId"] = accountId[0].fetch("Id")
		contactJSON[1]["AccountId"] = accountId[1].fetch("Id")
		contactJSON[2]["AccountId"] = accountId[2].fetch("Id")
		contactJSON[3]["AccountId"] = accountId[3].fetch("Id")
		contactId = Salesforce.createRecords(@sfBulk,"Contact",contactJSON)
#puts "contact created"
		@recordToDelete.store("contact",contactId)
#puts contactId.inspect

		buildingIds = Salesforce.createRecords(@sfBulk,"Building__c",@sObjectRecords['ContractEvent']['Building__c'])
#puts "Building__c created"
		@recordToDelete.store("building",buildingIds)
#puts buildingIds.inspect

		@reservableJSON = @sObjectRecords['ContractEvent']['Reservable__c']
		#puts "@reservableJSON"
		#puts @reservableJSON
		@reservableJSON[0]["Building__c"] = buildingIds[0].fetch("Id")
		@reservableJSON[1]["Building__c"] = buildingIds[0].fetch("Id")
		@reservableJSON[2]["Building__c"] = buildingIds[0].fetch("Id")
		reservableId  = Salesforce.createRecords(@sfBulk,"Reservable__c",@reservableJSON)
#puts "reservable__c created"
#puts reservableId.inspect
		@recordToDelete.store("reservable__c",reservableId)
		return @recordToDelete

	end

#stageName value ==> 'Selling' , 'Closing' , 'Closed Won' ,'Closed Lost'
#buildingNumber ==> 0 ,1 ,2
#contractStage ==> Contract Sent , Contract Signed 
# accountNumber ==> 0-for Consumer, 1-for Consumer, 2-for Mid Market, 3-for Enterprise Solutions
	def createOpportunity(accountNumber,stageName, buildingNumber = nil ,contractUUID = nil,contractStage = nil)
		opportunityJSON = @sObjectRecords['ContractEvent']['Opportunity']

		opportunityJSON[0]["Contract_UUID__c"] = contractUUID
		opportunityJSON[0]["StageName"] = stageName
		opportunityJSON[0]["Contract_Stage__c"] = contractStage
		opportunityJSON[0]["Building__c"] = @recordToDelete['building'][buildingNumber].fetch('Id')
		opportunityJSON[0]["Primary_Member__c"] = @recordToDelete['contact'][0].fetch('Id')
		opportunityJSON[0]["AccountId"] = @recordToDelete['account'][accountNumber].fetch('Id')

		opportunityIds = Salesforce.createRecords(@sfBulk,"Opportunity",opportunityJSON)

		@recordToDelete.store("opportunity",opportunityIds)

		return opportunityIds
	end

	def deleteCreatedOpportunities(opportunityIds)
		Salesforce.deleteRecords(@sfBulk,"Opportunity",opportunityIds)
	end

	def setUpPayload(eventName,opportunity_id = nil,company_uuid = nil,membership_agreement_uuid = nil,productCode = nil,reservableNumberForMoveIn= nil,reservableNumberForMoveOuts = nil,transferType= nil,downgradeReason = nil,downgradeNotes = nil)
		payload = @sObjectRecords['ContractEvent']['Scenarios'][0]
		payload['body']['event_name'] = "#{eventName}"
		payload['body']['opportunity_id'] = "#{opportunity_id}"
		payload['body']['company_uuid'] = "#{company_uuid}"
		payload['body']['membership_agreement_uuid'] = "#{membership_agreement_uuid}"
		payload['body']['transfer_type'] = "#{transferType}"
		payload['body']['downgrade_reason'] = "#{downgradeReason}"
		payload['body']['downgrade_notes'] = "#{downgradeNotes}"

		payload['body']['move_ins'][0]['reservable_uuid'] = @reservableJSON[reservableNumberForMoveIn]["UUID__c"]
		payload['body']['move_outs'][0]['reservable_uuid'] = @reservableJSON[reservableNumberForMoveOuts]["UUID__c"]

		payload['body']['transfer_type'] = "#{transferType}"

		if productCode != nil then
			payload['body']['products'][0]['product_code'] = productCode
		end
		
		if transferType == "Drop" then
			puts "product and move in deleted from payload"
			payload['body']['transfer_type'] = "Downgrade"
			payload = payload['body'].except('products','move_ins')
			newPayload = Hash.new()
			newPayload.store('body',payload)
			#puts newPayload
			return newPayload
		end

		if transferType == "New Business" then
			puts "move outs deleted from payload"
			#payload['body']['transfer_type'] = "Downgrade"
			payload = payload['body'].except('move_outs')
			newPayload = Hash.new()
			newPayload.store('body',payload)
			#puts newPayload
			return newPayload
		end
		#puts "Payload ==============>"
		#puts payload
		return payload
	end

	def deleteCreatedRecord()
		#Reservable automatically deleted when we delete building
		#Salesforce.deleteRecords(@sfBulk,"Reservable__c",@recordToDelete["reservable__c"])
		Salesforce.deleteRecords(@sfBulk,"Building__c",@recordToDelete["building"])
		#contact automatically deleted when we delete account
		Salesforce.deleteRecords(@sfBulk,"Contact",@recordToDelete["contact"])
		Salesforce.deleteRecords(@sfBulk,"Account",@recordToDelete["account"])
	end


	def getOpportunityDetails(id)
		#puts "in getOpportunityDetails--->"
		opportunity = Salesforce.getRecords(@sfBulk,"Opportunity","SELECT Id,CloseDate,Contract_Sent_Date__c,Contract_Signed_On__c,Paperwork_Sent_On_Date__c,Contract_Stage__c,StageName,Total_Desks_Reserved__c,Total_Desks_Move_Outs__c,Total_Desks_Reserved_net__c,Contract_UUID__c,Send_Paperwork_By__c,Actual_Start_Date__c,Quantity__c,No_of_Desks_gross__c,Original_Contract_UUID__c,Building__c,Move_Out_Building__c,Owner.Username,No_of_Desks_unweighted__c,No_of_Desks_weighted__c,Probability,From_Opportunity_Move_Ins__c,Contract_Type__c FROM Opportunity WHERE Id='#{id}'")

		return opportunity.result.records[0]
	end

	def getOppReservableDetails(oppId)
		#puts "in getOppReservableDetails--->"
		oppReservable = Salesforce.getRecords(@sfBulk,"Opportunity_Reservable__c","SELECT Id,Pending_Desks__c,Start_Date__c,Monthly_Price__c FROM Opportunity_Reservable__c WHERE opportunity__c='#{oppId}'")
		return oppReservable.result.records[0]
	end

	def getOppMoveOutsDetails(oppId)
		#puts "in getOppMoveOutsDetails--->"
		oppMoveOuts = Salesforce.getRecords(@sfBulk,"Opportunity_Move_Outs__c","SELECT Id,Pending_Desks__c,Move_Out_Date__c FROM Opportunity_Move_Outs__c WHERE opportunity__c='#{oppId}'")
		return oppMoveOuts.result.records[0]
	end

end



=begin
contractEvent = ContractEvent.new()
puts contractEvent.createCommonTestData()
contractEvent = ContractEvent.new()
puts contractEvent.createCommonTestData()
puts contractEvent.setUpPayload("Contract Sent",nil,"companyUUID","membershipAgreementUUID",nil,0,1,"Drop")

puts contractEvent.setUpPayload("Contract Sent",nil,"companyUUID","membershipAgreementUUID",nil,0,1,"Drop")
=end






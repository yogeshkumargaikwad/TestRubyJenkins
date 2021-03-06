#Created By : Kishor Shinde
#Created Date : 19/1/2018
#Modified date :
require_relative File.expand_path('',Dir.pwd )+ '/GemUtilities/RollbarUtility/rollbarUtility.rb'
require_relative File.expand_path('', Dir.pwd) + '/ContractEvent/PageObjects/restAPITestContractEvent.rb'
require_relative File.expand_path('', Dir.pwd) + '/ContractEvent/Utilities/sfRESTService.rb'
require 'selenium-webdriver'
require 'rspec'
require 'date'
require 'securerandom'

=begin
RSpec.configure do |conf|
  #conf.filter_run_including [[:'C451' => true],[:"452"=> true]]
  #conf.before(:all, type: :model) do |group|
  # group.include_examples "451"
  conf.filter_run_including  :'452'
end
=end
=begin
RSpec.configure do |conf|
  #c.treat_symbols_as_metadata_keys_with_true_values = true
  puts "**********"
  conf.filter_run_including [[:'C451' => true],[:"452"=> true]]
  #conf.before(:all, type: :model) do |group|
   # group.include_examples "451"
  #end
  #"#{string}"
  #c.include_examples :'452'
  #c.filter_run :'452'
end
=end
 describe ContractEvent do
  before(:all) {
    @objRollbar = RollbarUtility.new()    
    puts "------------------------------------------------------------------------------------------------------------------"
    @config = YAML.load_file(File.expand_path('', Dir.pwd) + '/credentials.yaml')
    @testRailUtility = EnziTestRailUtility::TestRailUtility.new(@config['TestRail']['username'], @config['TestRail']['password'])
    #arrCaseIds = Array.new
    #if !ENV['SECTION_ID'].nil? && ENV['CASE_ID'].nil? then
      #@testRailUtility.getCases(ENV['PROJECT_ID'], ENV['SUIT_ID'], ENV['SECTION_ID']).each do |caseId|
        #arrCaseIds.push(caseId['id'])
      #end
    #else
      #if !ENV['CASE_ID'].nil? then
        #arrCaseIds.push(ENV['CASE_ID'])
      #end
    #end
    #if !ENV['SUIT_ID'].nil? && (!ENV['SECTION_ID'].nil? || !ENV['CASE_ID'].nil?) then
      #@run = @testRailUtility.addRun("ContractEvent Run",4,26,arrCaseIds)['id']
    #else
      #@run = ENV['RUN_ID']                                      
    #end
    #if ENV['RUN_ID'].nil? then
      #@runId = @testRailUtility.addRun("ContractEvent Run",4,26,arrCaseIds)['id']
    #end
    @run = ENV['RUN_ID'] 
    testDataFile = File.open(File.expand_path('', Dir.pwd) + "/ContractEvent/TestData/testRecords.json", "r")
    testDataInJson = testDataFile.read()
    @testData = JSON.parse(testDataInJson)
    @sfRESTService = SfRESTService.new()
    @contractEvent = ContractEvent.new()
    #puts "Creating Common Test Data..."
    @recordCreated = @contractEvent.createCommonTestData()
    #puts @recordCreated
  }
  before(:each) {
    puts ""
    puts "------------------------------------------------------------------------------------------------------------------"
  }
  context 'ContractEvent-->sent', :'72' => true do
    #******************************** upgrade ****************************************
    it 'C:451 In Upgrade event, To check if the membership_agreement_uuid matched with the existing membership_agreement_uuid while hitting payload then existing opportunity should be updated.', :"451" => true do
      begin
        caseInfo = @testRailUtility.getCase('451')
        #puts caseInfo
        puts 'C:451 In Upgrade event, To check if the membership_agreement_uuid matched with the existing membership_agreement_uuid while hitting payload then existing opportunity should be updated.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = contractUUID
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Name:'#{@testData['ContractEvent']['Account'][1]['name']}', Stage:'Closing', Building:'#{@testData['ContractEvent']['Building__c'][0]['Name']}', Contract UUID:'#{contractUUID}'", caseInfo['id'])
        @opportunity = @contractEvent.createOpportunity(1, 'Closing', 0, contractUUID, nil)
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        
        
        @mapOpportunityId["opportunity"] = @opportunity
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Membership Agreement UUID'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", nil, companyUUID, membershipAgreementUUID, nil, 0, 1, "Upgrade").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
        expect(@getResponse['success']).to be true
        expect(@getResponse['result']).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected] Payload is successfully created and hitted")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
       
        id = @getResponse['result'].split(':')[1].chomp('"').delete(' ')
        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Update after hitting Payload?")
        expect(id).to eq  @opportunity[0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully updated")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        updatedOpp = @contractEvent.getOpportunityDetails(id)
       
        passedLogs = @objRollbar.addLog("[Step    ] Fetching Updated Opportunity details after hitting payload")
        expect(updatedOpp.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity fields are successfully fetched")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        
        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details for Opportunity:'#{@testData['ContractEvent']['Account'][1]['name']}'")
        updatedOppReservable = @contractEvent.getOppReservableDetails(updatedOpp.fetch("Id"))
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Move Outs details for Opportunity:'#{@testData['ContractEvent']['Account'][1]['name']}'")
        updatedOppMoveOuts = @contractEvent.getOppMoveOutsDetails(updatedOpp.fetch("Id"))
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Move Outs fields are successfully fetched")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Fields for Opportunity:'#{@testData['ContractEvent']['Account'][1]['name']}'")
        puts "\n"
        

        passedLogs = @objRollbar.addLog("[Validate] Does Paperwork Sent On Date Update to Contract Date?")
        passedLogs = @objRollbar.addLog("[Expected] Paperwork sent on Date= '#{@testData['ContractEvent']['Scenarios'][0]['body']['contract_date']}'")
        expect(updatedOpp.fetch("Paperwork_Sent_On_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['contract_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"        
        
        passedLogs = @objRollbar.addLog("[Validate] Does Contract UUID Update to Membership Agreement UUID?")
        passedLogs = @objRollbar.addLog("[Expected] Contract UUID= #{membershipAgreementUUID}")
        expect(updatedOpp.fetch("Contract_UUID__c")).to eq membershipAgreementUUID
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        
        
        passedLogs = @objRollbar.addLog("[Validate] Does Contract Stage Update to Contract Sent?") 
        passedLogs = @objRollbar.addLog("[Expected] Contract Stage= Contract Sent") 
        expect(updatedOpp.fetch("Contract_Stage__c")).to eq "Contract Sent"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 
        

        passedLogs = @objRollbar.addLog("[Validate] Does Paperwork Sent By Update to Contact Id?") 
        passedLogs = @objRollbar.addLog("[Expected] Paperwork Sent By=#{@recordCreated['contact'][1].fetch("Id")}") 
        expect(updatedOpp.fetch("Send_Paperwork_By__c")).to eq @recordCreated['contact'][1].fetch("Id")
        expect(updatedOpp.fetch("Send_Paperwork_By__c")).to eq @recordCreated['contact'][1].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 
        

        passedLogs = @objRollbar.addLog("[Validate] Does Actual Start Date Update to Start Date?") 
        passedLogs = @objRollbar.addLog("[Expected] Actual Start Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date']}") 
        expect(updatedOpp.fetch("Actual_Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 
        

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Reserved Update to Moveins Quantity?") 
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Reserved=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity']}")
        expect(updatedOpp.fetch("Total_Desks_Reserved__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success") 
        puts "\n"
        

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Moveout Should Update to Moveouts Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Move out=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity']}")
        expect(updatedOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Reserved(net) Update With Difference Between Opportunity Move ins and Opportunity Move Outs?")
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Reserved(Net)=#{(@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i)-(@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)}")
        expect(updatedOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks Update to Sum of Quantity of Product?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity']}")
        expect(updatedOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Gross) Update to Product Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks(Gross)=#{@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity']}")
        expect(updatedOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        

        passedLogs = @objRollbar.addLog("[Validate] Does Original Contract UUID Update to Membership Agreement UUID?")
        passedLogs = @objRollbar.addLog("[Expected] Original Contract UUID=#{membershipAgreementUUID}")
        expect(updatedOpp.fetch("Original_Contract_UUID__c")).to eq membershipAgreementUUID
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Stage Update to Closing?")
        passedLogs = @objRollbar.addLog("[Expected] Stage Name= Closing")
        expect(updatedOpp.fetch("StageName")).to eq "Closing"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Building Update to Move ins Building Passing through Payload?")
        passedLogs = @objRollbar.addLog("[Expected] Building=#{@recordCreated['building'][0].fetch("Id")}")
        expect(updatedOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        

        passedLogs = @objRollbar.addLog("[Validate] Does Move out Building Update to Building from Which Move Out Occured?")
        passedLogs = @objRollbar.addLog("[Expected] Move out Building=#{@recordCreated['building'][0].fetch("Id")}")
        expect(updatedOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        
        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Unweighted) Update?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks(Unweighted)=#{(@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i) - (@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)}")
        expect(updatedOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"        

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Weighted) Update?")
        weightedDesk = (updatedOpp.fetch("No_of_Desks_unweighted__c").to_f * (updatedOpp.fetch("Probability").to_f / 100.to_f).to_f).round
        passedlogs = @objRollbar.addLog("[Expected] No of Desks(Weighted)=#{weightedDesk}")
        expect(updatedOpp.fetch("No_of_Desks_weighted__c").to_i).to eq weightedDesk
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        
        
        passedLogs = @objRollbar.addLog("[Validate] Does Contract type Update to Upgrade?")
        passedLogs = @objRollbar.addLog("[Expected] Contract Type= Upgrade")
        expect(updatedOpp.fetch("Contract_Type__c")).to eq "Upgrade"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        
        
        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Reservables")
        puts "\n"
        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Reservable not null?")
        expect(updatedOppReservable.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        

        passedLogs = @objRollbar.addLog("[Validate] Does Pending desks in Opportunity Reservables Update to Move ins Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Pending Desks in Opportunity reservable=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity']}")
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Start date in Opportunity Reservable Update With Move ins Start Date?")
        passedLogs = @objRollbar.addLog("[Expected] Start Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date']}")
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Monthly Price on Opportunity Reservable update to Move ins price?")
        passedLogs = @objRollbar.addLog("[Expected] Monthly Price=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price']}")
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Move Outs")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Move Outs not null?")
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Pending Desks in Opportunity Move outs update With Move outs Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Pending Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity']}")
        
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Move out Date in Opportunity Move out Update?")
        passedLogs = @objRollbar.addLog("[Expected] Move out Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date']}")
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        puts "------------------------------------------------------------------------------------------------------------------"
        passedLogs = @objRollbar.addLog("[Step    ] Adding result in TestRail")
        @testRailUtility.postResult(451, "pass", 1, @run)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        rescue Exception => e
        #puts passedLogs[caseInfo['id']]
        passedLogs = @objRollbar.addLog("[Result  ] Failed")
        @objRollbar.postRollbarData(caseInfo['id'], caseInfo['title'], passedLogs[caseInfo['id']])
        
        #Rollbar.log("debug",passedLogs['id'])
        Rollbar.error(e)
        @testRailUtility.postResult(451, e, 5, @run)
        raise e
      end
    end

    it 'C:452 In Upgrade event, To check if opportunity id in the payload is matched with the opportunity_id in the system after hitting payload then existing opportunity in the system will be updated.', :'452'=> 'true' do
      begin
        caseInfo = @testRailUtility.getCase('452')
        puts 'C:452 In Upgrade event, To check if opportunity id in the payload is matched with the opportunity_id in the system after hitting payload then existing opportunity in the system will be updated.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Name:'#{@testData['ContractEvent']['Account'][1]['name']}', Stage:'Closing', Building:'#{@testData['ContractEvent']['Building__c'][0]['Name']}", caseInfo['id'])
        @opportunity = @contractEvent.createOpportunity(1, "selling", 0, nil, nil)
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        @mapOpportunityId["opportunity"] = @opportunity
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Opportunity Id'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", @opportunity[0].fetch("Id"), companyUUID, membershipAgreementUUID, nil, 0, 1, "Upgrade").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
        expect(@getResponse['success']).to be true
        expect(@getResponse['result']).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected] Payload is successfully created and hitted")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        id = @getResponse['result'].split(':')[1].chomp('"').delete(' ')
        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Update after hitting Payload?")
        expect(id).to eq  @opportunity[0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully updated")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        updatedOpp = @contractEvent.getOpportunityDetails(id)
        passedLogs = @objRollbar.addLog("[Step    ] Fetching Updated Opportunity details")
        expect(updatedOpp.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity fields are successfully fetched")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details")
        updatedOppReservable = @contractEvent.getOppReservableDetails(updatedOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Move Outs details")
        updatedOppMoveOuts = @contractEvent.getOppMoveOutsDetails(updatedOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Move Outs fields are successfully fetched")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Fields")
        puts "\n"
            
        passedLogs = @objRollbar.addLog("[Validate] Does Paperwork Sent On Date Update to Contract Date?")
        passedLogs = @objRollbar.addLog("[Expected] Paperwork sent on Date= '#{@testData['ContractEvent']['Scenarios'][0]['body']['contract_date']}'")
        expect(updatedOpp.fetch("Paperwork_Sent_On_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['contract_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Contract UUID Update to Membership Agreement UUID?")
        passedLogs = @objRollbar.addLog("[Expected] Contract UUID= #{membershipAgreementUUID}")
        expect(updatedOpp.fetch("Contract_UUID__c")).to eq membershipAgreementUUID
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Contract Stage Update to Contract Sent?") 
        passedLogs = @objRollbar.addLog("[Expected] Contract Stage= Contract Sent") 
        expect(updatedOpp.fetch("Contract_Stage__c")).to eq "Contract Sent"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Paperwork Sent By Update to Contact Id?") 
        passedLogs = @objRollbar.addLog("[Expected] Paperwork Sent By=#{@recordCreated['contact'][1].fetch("Id")}") 
        expect(updatedOpp.fetch("Send_Paperwork_By__c")).to eq @recordCreated['contact'][1].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Actual Start Date Update to Start Date?") 
        passedLogs = @objRollbar.addLog("[Expected] Actual Start Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date']}") 
        expect(updatedOpp.fetch("Actual_Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Reserved Update to Moveins Quantity?") 
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Reserved=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity']}")
        expect(updatedOpp.fetch("Total_Desks_Reserved__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Moveout Should Update to Moveouts Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Move out=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity']}")
        expect(updatedOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Reserved(net) Update With Difference Between Opportunity Move ins and Opportunity Move Outs?")
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Reserved(Net)=#{(@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i)-(@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)}")
        expect(updatedOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks Update to Sum of Quantity of Product?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity']}")
        expect(updatedOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Gross) Update to Product Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks(Gross)=#{@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity']}")
        expect(updatedOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Original Contract UUID Update to Membership Agreement UUID?")
        passedLogs = @objRollbar.addLog("[Expected] Original Contract UUID= ")
        expect(updatedOpp.fetch("Original_Contract_UUID__c")).to eq ""
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Stage Update to Closing?")
        passedLogs = @objRollbar.addLog("[Expected] Stage Name= Closing")
        expect(updatedOpp.fetch("StageName")).to eq "Closing"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Building Update to Move ins Building Passing through Payload?")
        passedLogs = @objRollbar.addLog("[Expected] Building=#{@recordCreated['building'][0].fetch("Id")}")
        expect(updatedOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Move out Building Update to Building from Which Move Out Occured?")
        passedLogs = @objRollbar.addLog("[Expected] Move out Building=#{@recordCreated['building'][0].fetch("Id")}")
        expect(updatedOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Unweighted) Update?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks(Unweighted)=#{(@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i) - (@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)}")
        expect(updatedOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Weighted) Update?")
        weightedDesk = (updatedOpp.fetch("No_of_Desks_unweighted__c").to_f * (updatedOpp.fetch("Probability").to_f / 100.to_f).to_f).round
        passedlogs = @objRollbar.addLog("[Expected] No of Desks(Weighted)=#{weightedDesk}")
        expect(updatedOpp.fetch("No_of_Desks_weighted__c").to_i).to eq weightedDesk
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Contract type Update to Upgrade?")
        passedLogs = @objRollbar.addLog("[Expected] Contract Type= Upgrade")
        expect(updatedOpp.fetch("Contract_Type__c")).to eq "Upgrade"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Reservables")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Reservable not null?")
        expect(updatedOppReservable.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Pending desks in Opportunity Reservables Update to Move ins Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Pending Desks in Opportunity reservable=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity']}")
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 


        passedLogs = @objRollbar.addLog("[Validate] Does Start date in Opportunity Reservable Update With Move ins Start Date?")
        passedLogs = @objRollbar.addLog("[Expected] Start Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date']}")
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Monthly Price on Opportunity Reservable update to Move ins price?")
        passedLogs = @objRollbar.addLog("[Expected] Monthly Price=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price']}")
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Move Outs")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Move Outs not null?")
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Pending Desks in Opportunity Move outs update With Move outs Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Pending Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity']}")
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Move out Date in Opportunity Move out Update?")
        passedLogs = @objRollbar.addLog("[Expected] Move out Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date']}")
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "------------------------------------------------------------------------------------------------------------------"
        passedLogs = @objRollbar.addLog("[Step    ] Adding result in TestRail")
        @testRailUtility.postResult(452, "pass", 1, @run)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        rescue Exception => e
        passedLogs = @objRollbar.addLog("[Result  ] Failed")
        @objRollbar.postRollbarData(caseInfo['id'], caseInfo['title'], passedLogs[caseInfo['id']])
        Rollbar.error(e)
        @testRailUtility.postResult(452, e, 5, @run)
        raise e
      end
    end

    it 'C:453 In Upgrade event, To check if company_uuid in the payload matched with the existing account in the system, there are having open opportunities after hitting payload if building matched with the existing open opportunity then existing opportunity should be updated.', :'453' => true do
      begin
        caseInfo = @testRailUtility.getCase('453')
        puts 'C:453 In Upgrade event, To check if company_uuid in the payload matched with the existing account in the system, there are having open opportunities after hitting payload if building matched with the existing open opportunity then existing opportunity should be updated.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Name:'#{@testData['ContractEvent']['Account'][1]['name']}', Stage:'Selling', Building:'#{@testData['ContractEvent']['Building__c'][0]['Name']}", caseInfo['id'])
        @opportunity1 = @contractEvent.createOpportunity(1, "selling", 0, nil)
        expect(@opportunity1).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Name:'#{@testData['ContractEvent']['Account'][1]['name']}', Stage:'Selling', Building:'#{@testData['ContractEvent']['Building__c'][1]['Name']}")
        @opportunity2 = @contractEvent.createOpportunity(1, "selling", 1, nil)
        expect(@opportunity2).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        @mapOpportunityId["opportunity"] = @opportunity1
        @mapOpportunityId["opportunity"] << @opportunity2

        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Company UUID'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", nil, "#{@testData['ContractEvent']['Account'][1]['UUID__c']}", membershipAgreementUUID, nil, 0, 1, "Upgrade").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
        expect(@getResponse['success']).to be true
        expect(@getResponse['result']).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected] Payload is successfully created and hitted")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        id = @getResponse['result'].split(':')[1].chomp('"').delete(' ')
        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Update after hitting Payload?")
        expect(id).to eq  @opportunity1[0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully updated")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        updatedOpp = @contractEvent.getOpportunityDetails(id)
        passedLogs = @objRollbar.addLog("[Step    ] Fetching Updated Opportunity details")
        expect(updatedOpp.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity fields are successfully fetched")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details")
        updatedOppReservable = @contractEvent.getOppReservableDetails(updatedOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Move Outs details")
        updatedOppMoveOuts = @contractEvent.getOppMoveOutsDetails(updatedOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Move Outs fields are successfully fetched")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Fields")
        puts "\n"
        

        passedLogs = @objRollbar.addLog("[Validate] Does Paperwork Sent On Date Update to Contract Date?")
        passedLogs = @objRollbar.addLog("[Expected] Paperwork sent on Date= '#{@testData['ContractEvent']['Scenarios'][0]['body']['contract_date']}'")
        expect(updatedOpp.fetch("Paperwork_Sent_On_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['contract_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Contract UUID Update to Membership Agreement UUID?")
        passedLogs = @objRollbar.addLog("[Expected] Contract UUID= #{membershipAgreementUUID}")
        expect(updatedOpp.fetch("Contract_UUID__c")).to eq membershipAgreementUUID
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Contract Stage Update to Contract Sent?") 
        passedLogs = @objRollbar.addLog("[Expected] Contract Stage= Contract Sent") 
        expect(updatedOpp.fetch("Contract_Stage__c")).to eq "Contract Sent"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Paperwork Sent By Update to Contact Id?") 
        passedLogs = @objRollbar.addLog("[Expected] Paperwork Sent By=#{@recordCreated['contact'][1].fetch("Id")}") 
        expect(updatedOpp.fetch("Send_Paperwork_By__c")).to eq @recordCreated['contact'][1].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Actual Start Date Update to Start Date?") 
        passedLogs = @objRollbar.addLog("[Expected] Actual Start Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date']}") 
        expect(updatedOpp.fetch("Actual_Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Reserved Update to Moveins Quantity?") 
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Reserved=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity']}")
        expect(updatedOpp.fetch("Total_Desks_Reserved__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Moveout Should Update to Moveouts Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Move out=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity']}")
        expect(updatedOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Reserved(net) Update With Difference Between Opportunity Move ins and Opportunity Move Outs?")
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Reserved(Net)=#{(@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i)-(@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)}")
        expect(updatedOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks Update to Sum of Quantity of Product?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity']}")
        expect(updatedOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Gross) Update to Product Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks(Gross)=#{@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity']}")
        expect(updatedOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Original Contract UUID Update to Membership Agreement UUID?")
        passedLogs = @objRollbar.addLog("[Expected] Original Contract UUID= ")
        expect(updatedOpp.fetch("Original_Contract_UUID__c")).to eq ""
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Stage Update to Closing?")
        passedLogs = @objRollbar.addLog("[Expected] Stage Name= Closing")
        expect(updatedOpp.fetch("StageName")).to eq "Closing"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Building Update to Move ins Building Passing through Payload?")
        passedLogs = @objRollbar.addLog("[Expected] Building=#{@recordCreated['building'][0].fetch("Id")}")
        expect(updatedOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Move out Building Update to Building from Which Move Out Occured?")
        passedLogs = @objRollbar.addLog("[Expected] Move out Building=#{@recordCreated['building'][0].fetch("Id")}")
        expect(updatedOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Unweighted) Update?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks(Unweighted)=#{(@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i) - (@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)}")
        expect(updatedOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Weighted) Update?")
        weightedDesk = (updatedOpp.fetch("No_of_Desks_unweighted__c").to_f * (updatedOpp.fetch("Probability").to_f / 100.to_f).to_f).round
        passedlogs = @objRollbar.addLog("[Expected] No of Desks(Weighted)=#{weightedDesk}")
        expect(updatedOpp.fetch("No_of_Desks_weighted__c").to_i).to eq weightedDesk
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Contract type Update to Upgrade?")
        passedLogs = @objRollbar.addLog("[Expected] Contract Type= Upgrade")
        expect(updatedOpp.fetch("Contract_Type__c")).to eq "Upgrade"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

       
        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Reservables")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Reservable not null?")
        expect(updatedOppReservable.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Pending desks in Opportunity Reservables Update to Move ins Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Pending Desks in Opportunity reservable=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity']}")
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Start date in Opportunity Reservable Update With Move ins Start Date?")
        passedLogs = @objRollbar.addLog("[Expected] Start Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date']}")
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Monthly Price on Opportunity Reservable update to Move ins price?")
        passedLogs = @objRollbar.addLog("[Expected] Monthly Price=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price']}")
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 
    
        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Move Outs")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Move Outs not null?")
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Pending Desks in Opportunity Move outs update With Move outs Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Pending Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity']}")
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Move out Date in Opportunity Move out Update?")
        passedLogs = @objRollbar.addLog("[Expected] Move out Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date']}")
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "------------------------------------------------------------------------------------------------------------------"
        passedLogs = @objRollbar.addLog("[Step    ] Adding result in TestRail")
        @testRailUtility.postResult(453, "pass", 1, @run)
        passedLogs = @objRollbar.addLog("[Result  ] Success")

        @testRailUtility.postResult(453, "pass", 1, @run)
        rescue Exception => e
        passedLogs = @objRollbar.addLog("[Result  ] Failed")
        @objRollbar.postRollbarData(caseInfo['id'], caseInfo['title'], passedLogs[caseInfo['id']])
        Rollbar.error(e)
        @testRailUtility.postResult(453, e, 5, @run)
        raise e
      end
    end

    it 'C:726 In Upgrade event, To check if company_uuid in the payload matched with the existing account in the system, there are having open opportunities after hitting payload if building does not matched with the existing open opportunity then latest opportunity will be updated.', :'726' => true do
      begin
        caseInfo = @testRailUtility.getCase('726')
        puts 'C:726 In Upgrade event, To check if company_uuid in the payload matched with the existing account in the system, there are having open opportunities after hitting payload if building does not matched with the existing open opportunity then latest opportunity will be updated.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        
        #@contractEvent.createOpportunity(stageName = nil, buildingNumber = nil ,contractUUID = nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Name:'#{@testData['ContractEvent']['Account'][1]['name']}', Stage:'Selling', Building:'#{@testData['ContractEvent']['Building__c'][1]['Name']}", caseInfo['id'])
        @opportunity1 = @contractEvent.createOpportunity(1, "selling", 1, nil)
        expect(@opportunity1).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Name:'#{@testData['ContractEvent']['Account'][1]['name']}', Stage:'Selling', Building:'#{@testData['ContractEvent']['Building__c'][2]['Name']}")
        @opportunity2 = @contractEvent.createOpportunity(1, "selling", 2, nil)
        expect(@opportunity2).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        @mapOpportunityId["opportunity"] = @opportunity1
        @mapOpportunityId["opportunity"] << @opportunity2

        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Company UUID'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", nil, "#{@testData['ContractEvent']['Account'][1]['UUID__c']}", membershipAgreementUUID, nil, 0, 1, "Upgrade").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
        expect(@getResponse['success']).to be true
        expect(@getResponse['result']).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected] Payload is successfully created and hitted")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        id = @getResponse['result'].split(':')[1].chomp('"').delete(' ')
        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Update after hitting Payload?")
        expect(id).to eq  @opportunity2[0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully updated")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        updatedOpp = @contractEvent.getOpportunityDetails(id)
        passedLogs = @objRollbar.addLog("[Step    ] Fetching Updated Opportunity details")
        expect(updatedOpp.fetch("Id")).to eq @opportunity2[0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Expected] Opportunity fields are successfully fetched")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details")
        updatedOppReservable = @contractEvent.getOppReservableDetails(updatedOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Move Outs details")
        updatedOppMoveOuts = @contractEvent.getOppMoveOutsDetails(updatedOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Move Outs fields are successfully fetched")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Fields")
        puts "\n"
        
        passedLogs = @objRollbar.addLog("[Validate] Does Paperwork Sent On Date Update to Contract Date?")
        passedLogs = @objRollbar.addLog("[Expected] Paperwork sent on Date= '#{@testData['ContractEvent']['Scenarios'][0]['body']['contract_date']}'")
        expect(updatedOpp.fetch("Paperwork_Sent_On_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['contract_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Contract UUID Update to Membership Agreement UUID?")
        passedLogs = @objRollbar.addLog("[Expected] Contract UUID= #{membershipAgreementUUID}")
        expect(updatedOpp.fetch("Contract_UUID__c")).to eq membershipAgreementUUID
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Contract Stage Update to Contract Sent?") 
        passedLogs = @objRollbar.addLog("[Expected] Contract Stage= Contract Sent") 
        expect(updatedOpp.fetch("Contract_Stage__c")).to eq "Contract Sent"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Paperwork Sent By Update to Contact Id?") 
        passedLogs = @objRollbar.addLog("[Expected] Paperwork Sent By=#{@recordCreated['contact'][1].fetch("Id")}") 
        expect(updatedOpp.fetch("Send_Paperwork_By__c")).to eq @recordCreated['contact'][1].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Actual Start Date Update to Start Date?") 
        passedLogs = @objRollbar.addLog("[Expected] Actual Start Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date']}") 
        expect(updatedOpp.fetch("Actual_Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Reserved Update to Moveins Quantity?") 
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Reserved=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity']}")
        expect(updatedOpp.fetch("Total_Desks_Reserved__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Moveout Should Update to Moveouts Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Move out=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity']}")
        expect(updatedOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Reserved(net) Update With Difference Between Opportunity Move ins and Opportunity Move Outs?")
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Reserved(Net)=#{(@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i)-(@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)}")
        expect(updatedOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks Update to Sum of Quantity of Product?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity']}")
        expect(updatedOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Gross) Update to Product Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks(Gross)=#{@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity']}")
        expect(updatedOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Original Contract UUID Update to Membership Agreement UUID?")
        passedLogs = @objRollbar.addLog("[Expected] Original Contract UUID= ")
        expect(updatedOpp.fetch("Original_Contract_UUID__c")).to eq ""
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Stage Update to Closing?")
        passedLogs = @objRollbar.addLog("[Expected] Stage Name= Closing")
        expect(updatedOpp.fetch("StageName")).to eq "Closing"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Building Update to Move ins Building Passing through Payload?")
        passedLogs = @objRollbar.addLog("[Expected] Building=#{@recordCreated['building'][0].fetch("Id")}")
        expect(updatedOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Move out Building Update to Building from Which Move Out Occured?")
        passedLogs = @objRollbar.addLog("[Expected] Move out Building=#{@recordCreated['building'][0].fetch("Id")}")
        expect(updatedOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Unweighted) Update?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks(Unweighted)=#{(@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i) - (@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)}")
        expect(updatedOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Weighted) Update?")
        weightedDesk = (updatedOpp.fetch("No_of_Desks_unweighted__c").to_f * (updatedOpp.fetch("Probability").to_f / 100.to_f).to_f).round
        passedlogs = @objRollbar.addLog("[Expected] No of Desks(Weighted)=#{weightedDesk}")
        expect(updatedOpp.fetch("No_of_Desks_weighted__c").to_i).to eq weightedDesk
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Contract type Update to Upgrade?")
        passedLogs = @objRollbar.addLog("[Expected] Contract Type= Upgrade")
        expect(updatedOpp.fetch("Contract_Type__c")).to eq "Upgrade"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 
        
        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Reservables")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Reservable not null?")
        expect(updatedOppReservable.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Pending desks in Opportunity Reservables Update to Move ins Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Pending Desks in Opportunity reservable=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity']}")
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Start date in Opportunity Reservable Update With Move ins Start Date?")
        passedLogs = @objRollbar.addLog("[Expected] Start Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date']}")
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Monthly Price on Opportunity Reservable update to Move ins price?")
        passedLogs = @objRollbar.addLog("[Expected] Monthly Price=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price']}")
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Move Outs")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Move Outs not null?")
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Pending Desks in Opportunity Move outs update With Move outs Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Pending Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity']}")
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 
        
        passedLogs = @objRollbar.addLog("[Validate] Does Move out Date in Opportunity Move out Update?")
        passedLogs = @objRollbar.addLog("[Expected] Move out Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date']}")
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 
        puts "------------------------------------------------------------------------------------------------------------------"
        
        passedLogs = @objRollbar.addLog("[Step    ] Adding result in TestRail")
        @testRailUtility.postResult(726, "pass", 1, @run)
        passedLogs = @objRollbar.addLog("[Result  ] Success")

        @testRailUtility.postResult(726, "pass", 1, @run)
        rescue Exception => e
        passedLogs = @objRollbar.addLog("[Result  ] Failed")
        @objRollbar.postRollbarData(caseInfo['id'], caseInfo['title'], passedLogs[caseInfo['id']])
        Rollbar.error(e)
        @testRailUtility.postResult(726, e, 5, @run)
        raise e
      end
    end

    it 'C:857 In Upgrade event, To check if company_uuid matched with the existing opportunity and for that account there is having opportunity with the stages closed won or closed lost, while hitting payload for a particular building then new opportunity should be created.', :'857' => true do
      begin
        caseInfo = @testRailUtility.getCase('857')
        puts 'C:857 In Upgrade event, To check if company_uuid matched with the existing opportunity and for that account there is having opportunity with the stages closed won or closed lost, while hitting payload for a particular building then new opportunity should be created.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        
        
        #@contractEvent.createOpportunity(stageName = nil, buildingNumber = nil ,contractUUID = nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Name:'#{@testData['ContractEvent']['Account'][1]['name']}', Stage:'Closed Won', Building:'#{@testData['ContractEvent']['Building__c'][1]['Name']},Contract UUID:'#{contractUUID}'",caseInfo['id'])
        @opportunity1 = @contractEvent.createOpportunity(1, "Closed Won", 1, contractUUID)
        expect(@opportunity1).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Name:'#{@testData['ContractEvent']['Account'][1]['name']}', Stage:'Closed Lost', Building:'#{@testData['ContractEvent']['Building__c'][2]['Name']}")
        @opportunity2 = @contractEvent.createOpportunity(1, "Closed Lost", 2, nil)
        expect(@opportunity2).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        
        @mapOpportunityId["opportunity"] = @opportunity1
        @mapOpportunityId["opportunity"] << @opportunity2

        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based On Company UUID'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", nil, "#{@testData['ContractEvent']['Account'][1]['UUID__c']}", membershipAgreementUUID, nil, 0, 1, "Upgrade").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
        puts @getResponse
        expect(@getResponse['success']).to be true
        expect(@getResponse['result']).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected] Payload is successfully created and hitted")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        id = @getResponse['result'].split(':')[1].chomp('"').delete(' ')
        Salesforce.addRecordsToDelete('Opportunity',id)
        passedLogs = @objRollbar.addLog("[Validate] Does New Opportunity created after hitting Payload?")
        createdOpp = @contractEvent.getOpportunityDetails(id)
        expect(createdOpp.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        @mapOpportunityId["opportunity"] << Hash["Id" => id]

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details")
        updatedOppReservable = @contractEvent.getOppReservableDetails(createdOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Move Outs details")
        updatedOppMoveOuts = @contractEvent.getOppMoveOutsDetails(createdOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Move Outs fields are successfully fetched")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Fields")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Paperwork Sent On Date Update to Contract Date?")
        passedLogs = @objRollbar.addLog("[Expected] Paperwork sent on Date= '#{@testData['ContractEvent']['Scenarios'][0]['body']['contract_date']}'")
        expect(createdOpp.fetch("Paperwork_Sent_On_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['contract_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Contract UUID Update to Membership Agreement UUID?")
        passedLogs = @objRollbar.addLog("[Expected] Contract UUID= #{membershipAgreementUUID}")
        expect(createdOpp.fetch("Contract_UUID__c")).to eq membershipAgreementUUID
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Contract Stage Update to Contract Sent?") 
        passedLogs = @objRollbar.addLog("[Expected] Contract Stage= Contract Sent") 
        expect(createdOpp.fetch("Contract_Stage__c")).to eq "Contract Sent"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Paperwork Sent By Update to Contact Id?") 
        passedLogs = @objRollbar.addLog("[Expected] Paperwork Sent By=#{@recordCreated['contact'][1].fetch("Id")}") 
        expect(createdOpp.fetch("Send_Paperwork_By__c")).to eq @recordCreated['contact'][1].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Actual Start Date Update to Start Date?") 
        passedLogs = @objRollbar.addLog("[Expected] Actual Start Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date']}") 
        expect(createdOpp.fetch("Actual_Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Reserved Update to Moveins Quantity?") 
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Reserved=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity']}")
        expect(createdOpp.fetch("Total_Desks_Reserved__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Moveout Should Update to Moveouts Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Move out=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity']}")
        expect(createdOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Reserved(net) Update With Difference Between Opportunity Move ins and Opportunity Move Outs?")
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Reserved(Net)=#{(@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i)-(@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)}")
        expect(createdOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks Update to Sum of Quantity of Product?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity']}")
        expect(createdOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Gross) Update to Product Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks(Gross)=#{@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity']}")
        expect(createdOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Original Contract UUID Update to Membership Agreement UUID?")
        passedLogs = @objRollbar.addLog("[Expected] Original Contract UUID= ")
        expect(createdOpp.fetch("Original_Contract_UUID__c")).to eq ""
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Stage Update to Closing?")
        passedLogs = @objRollbar.addLog("[Expected] Stage Name= Closing")
        expect(createdOpp.fetch("StageName")).to eq "Closing"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Building Update to Move ins Building Passing through Payload?")
        passedLogs = @objRollbar.addLog("[Expected] Building=#{@recordCreated['building'][0].fetch("Id")}")
        expect(createdOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Move out Building Update to Building from Which Move Out Occured?")
        passedLogs = @objRollbar.addLog("[Expected] Move out Building=#{@recordCreated['building'][0].fetch("Id")}")
        expect(createdOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Close date updated to One month forward?")
        d = Date.today
        passedLogs = @objRollbar.addLog("[Expected] Close Date=#{(d + 30).to_s}")
        expect(createdOpp.fetch("CloseDate")).to eq (d + 30).to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Owner Update?")
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Owner=#{@config['Staging']['username']}")
        expect(createdOpp.fetch("Owner.Username")).to eq @config['Staging']['username']
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Unweighted) Update?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks(Unweighted)=#{(@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i) - (@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)}")
        expect(createdOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Weighted) Update?")
        weightedDesk = (createdOpp.fetch("No_of_Desks_unweighted__c").to_f * (createdOpp.fetch("Probability").to_f / 100.to_f).to_f).round
        passedlogs = @objRollbar.addLog("[Expected] No of Desks(Weighted)=#{weightedDesk}")
        expect(createdOpp.fetch("No_of_Desks_weighted__c").to_i).to eq weightedDesk
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Contract type Update to Upgrade?")
        passedLogs = @objRollbar.addLog("[Expected] Contract Type= Upgrade")
        expect(createdOpp.fetch("Contract_Type__c")).to eq "Upgrade"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 
        
        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Reservables")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Reservable not null?")
        expect(updatedOppReservable.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Pending desks in Opportunity Reservables Update to Move ins Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Pending Desks in Opportunity reservable=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity']}")
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Start date in Opportunity Reservable Update With Move ins Start Date?")
        passedLogs = @objRollbar.addLog("[Expected] Start Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date']}")
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Monthly Price on Opportunity Reservable update to Move ins price?")
        passedLogs = @objRollbar.addLog("[Expected] Monthly Price=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price']}")
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 


        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Move Outs")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Move Outs not null?")
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Pending Desks in Opportunity Move outs update With Move outs Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Pending Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity']}")
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Move out Date in Opportunity Move out Update?")
        passedLogs = @objRollbar.addLog("[Expected] Move out Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date']}")
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 
        puts "------------------------------------------------------------------------------------------------------------------"
        
        passedLogs = @objRollbar.addLog("[Step    ] Adding result in TestRail")
        @testRailUtility.postResult(857, "pass", 1, @run)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        @testRailUtility.postResult(857, "pass", 1, @run)
        rescue Exception => e
        passedLogs = @objRollbar.addLog("[Result  ] Failed")
        @objRollbar.postRollbarData(caseInfo['id'], caseInfo['title'], passedLogs[caseInfo['id']])
        Rollbar.error(e)
        @testRailUtility.postResult(857, e, 5, @run)
        raise e
      end
    end

    it 'C:858 In Upgrade event, To check if the company_uuid matched with the existing opportunity and for that account there is having opportunity with stages closing and contract stage as sent then new opportunity should be created.', :'858' => true do
      begin
        caseInfo = @testRailUtility.getCase('858')
        puts 'C:858 In Upgrade event, To check if the company_uuid matched with the existing opportunity and for that account there is having opportunity with stages closing and contract stage as sent then new opportunity should be created.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Name:'#{@testData['ContractEvent']['Account'][1]['name']}', Stage:'Closing', Building:'#{@testData['ContractEvent']['Building__c'][1]['Name']},Contract UUID:'#{contractUUID}', Contract Stage 'Contract Sent'",caseInfo['id'])
        @opportunity = @contractEvent.createOpportunity(1, "Closing", 1, contractUUID, "Contract Sent")
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        @mapOpportunityId["opportunity"] = @opportunity
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Company UUID'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", nil, "#{@testData['ContractEvent']['Account'][1]['UUID__c']}", membershipAgreementUUID, nil, 0, 1, "Upgrade").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
        expect(@getResponse['success']).to be true
        expect(@getResponse['result']).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected] Payload is successfully created and hitted")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        id = @getResponse['result'].split(':')[1].chomp('"').delete(' ')
        passedLogs = @objRollbar.addLog("[Validate] Does New Opportunity created after hitting Payload?")
        createdOpp = @contractEvent.getOpportunityDetails(id)
        Salesforce.addRecordsToDelete('Opportunity',id)
        expect(createdOpp.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        @mapOpportunityId["opportunity"] << Hash["Id" => id]

        
        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details")
        updatedOppReservable = @contractEvent.getOppReservableDetails(createdOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Move Outs details")
        updatedOppMoveOuts = @contractEvent.getOppMoveOutsDetails(createdOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Move Outs fields are successfully fetched")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Fields")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Paperwork Sent On Date Update to Contract Date?")
        passedLogs = @objRollbar.addLog("[Expected] Paperwork sent on Date= '#{@testData['ContractEvent']['Scenarios'][0]['body']['contract_date']}'")
        expect(createdOpp.fetch("Paperwork_Sent_On_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['contract_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Contract UUID Update to Membership Agreement UUID?")
        passedLogs = @objRollbar.addLog("[Expected] Contract UUID= #{membershipAgreementUUID}")
        expect(createdOpp.fetch("Contract_UUID__c")).to eq membershipAgreementUUID
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Contract Stage Update to Contract Sent?") 
        passedLogs = @objRollbar.addLog("[Expected] Contract Stage= Contract Sent") 
        expect(createdOpp.fetch("Contract_Stage__c")).to eq "Contract Sent"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Paperwork Sent By Update to Contact Id?") 
        passedLogs = @objRollbar.addLog("[Expected] Paperwork Sent By=#{@recordCreated['contact'][1].fetch("Id")}") 
        expect(createdOpp.fetch("Send_Paperwork_By__c")).to eq @recordCreated['contact'][1].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Actual Start Date Update to Start Date?") 
        passedLogs = @objRollbar.addLog("[Expected] Actual Start Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date']}") 
        expect(createdOpp.fetch("Actual_Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Reserved Update to Moveins Quantity?") 
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Reserved=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity']}")
        expect(createdOpp.fetch("Total_Desks_Reserved__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Moveout Should Update to Moveouts Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Move out=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity']}")
        expect(createdOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Reserved(net) Update With Difference Between Opportunity Move ins and Opportunity Move Outs?")
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Reserved(Net)=#{(@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i)-(@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)}")
        expect(createdOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks Update to Sum of Quantity of Product?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity']}")
        expect(createdOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Gross) Update to Product Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks(Gross)=#{@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity']}")
        expect(createdOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Original Contract UUID Update to Membership Agreement UUID?")
        passedLogs = @objRollbar.addLog("[Expected] Original Contract UUID= ")
        expect(createdOpp.fetch("Original_Contract_UUID__c")).to eq ""
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Stage Update to Closing?")
        passedLogs = @objRollbar.addLog("[Expected] Stage Name= Closing")
        expect(createdOpp.fetch("StageName")).to eq "Closing"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Building Update to Move ins Building Passing through Payload?")
        passedLogs = @objRollbar.addLog("[Expected] Building=#{@recordCreated['building'][0].fetch("Id")}")
        expect(createdOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Move out Building Update to Building from Which Move Out Occured?")
        passedLogs = @objRollbar.addLog("[Expected] Move out Building=#{@recordCreated['building'][0].fetch("Id")}")
        expect(createdOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

=begin
        passedLogs = @objRollbar.addLog("[Validate] Does Close date updated to One monthe forward?")
        d = Date.today
        passedLogs = @objRollbar.addLog("[Expected] Close Date=#{(d + 30).to_s}")
        expect(createdOpp.fetch("CloseDate")).to eq (d + 30).to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 
=end
        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Owner Update?")
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Owner=#{@config['Staging']['username']}")
        expect(createdOpp.fetch("Owner.Username")).to eq @config['Staging']['username']
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Unweighted) Update?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks(Unweighted)=#{(@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i) - (@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)}")
        expect(createdOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Weighted) Update?")
        weightedDesk = (createdOpp.fetch("No_of_Desks_unweighted__c").to_f * (createdOpp.fetch("Probability").to_f / 100.to_f).to_f).round
        passedlogs = @objRollbar.addLog("[Expected] No of Desks(Weighted)=#{weightedDesk}")
        expect(createdOpp.fetch("No_of_Desks_weighted__c").to_i).to eq weightedDesk
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Contract type Update to Upgrade?")
        passedLogs = @objRollbar.addLog("[Expected] Contract Type= Upgrade")
        expect(createdOpp.fetch("Contract_Type__c")).to eq "Upgrade"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Reservables")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Reservable not null?")
        expect(updatedOppReservable.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Pending desks in Opportunity Reservables Update to Move ins Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Pending Desks in Opportunity reservable=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity']}")
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Start date in Opportunity Reservable Update With Move ins Start Date?")
        passedLogs = @objRollbar.addLog("[Expected] Start Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date']}")
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Monthly Price on Opportunity Reservable update to Move ins price?")
        passedLogs = @objRollbar.addLog("[Expected] Monthly Price=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price']}")
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Move Outs")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Move Outs not null?")
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Pending Desks in Opportunity Move outs update With Move outs Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Pending Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity']}")
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Move out Date in Opportunity Move out Update?")
        passedLogs = @objRollbar.addLog("[Expected] Move out Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date']}")
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        puts "------------------------------------------------------------------------------------------------------------------"
        
        passedLogs = @objRollbar.addLog("[Step    ] Adding result in TestRail")
        @testRailUtility.postResult(858, "pass", 1, @run)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        @testRailUtility.postResult(858, "pass", 1, @run)
        rescue Exception => e
        passedLogs = @objRollbar.addLog("[Result  ] Failed")
        @objRollbar.postRollbarData(caseInfo['id'], caseInfo['title'], passedLogs[caseInfo['id']])
        Rollbar.error(e)
        @testRailUtility.postResult(858, e, 5, @run)
        raise e
      end

    end

    it 'C:862 In Upgrade event, To check if the opportunity stage is closing but the contract stage is blank or other than contract sent or signed then new opportunity Should not be created.', :'862' => true do
      begin
        caseInfo = @testRailUtility.getCase('862')
        puts 'C:862 In Upgrade event, To check if the opportunity stage is closing but the contract stage is blank or other than contract sent or signed then new opportunity Should not be created.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Name:'#{@testData['ContractEvent']['Account'][1]['name']}', Stage:'Closing', Building:'#{@testData['ContractEvent']['Building__c'][1]['Name']},Contract UUID:'#{contractUUID}', Contract Stage 'Contract Discarded'",caseInfo['id'])
        @opportunity = @contractEvent.createOpportunity(1, "Closing", 1, contractUUID, "Contract Discarded")
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        @mapOpportunityId["opportunity"] = @opportunity
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Company UUID'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", nil, "#{@testData['ContractEvent']['Account'][1]['UUID__c']}", membershipAgreementUUID, nil, 0, 1, "Upgrade").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
        expect(@getResponse['success']).to be true
        expect(@getResponse['result']).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected] Payload is successfully created and hitted")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        id = @getResponse['result'].split(':')[1].chomp('"').delete(' ')
        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Update after hitting Payload?")
        expect(id).to eq  @opportunity[0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully updated")
        passedLogs = @objRollbar.addLog("[Result  ] Success")

        updatedOpp = @contractEvent.getOpportunityDetails(id)
        passedLogs = @objRollbar.addLog("[Step    ] Fetching Updated Opportunity details")
        expect(updatedOpp.fetch("Id")).to eq @opportunity[0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Expected] Opportunity fields are successfully fetched")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details")
        updatedOppReservable = @contractEvent.getOppReservableDetails(updatedOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        
        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Move Outs details")
        updatedOppMoveOuts = @contractEvent.getOppMoveOutsDetails(updatedOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Move Outs fields are successfully fetched")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Fields")
        puts "\n"
       
        passedLogs = @objRollbar.addLog("[Validate] Does Paperwork Sent On Date Update to Contract Date?")
        passedLogs = @objRollbar.addLog("[Expected] Paperwork sent on Date= '#{@testData['ContractEvent']['Scenarios'][0]['body']['contract_date']}'")
        expect(updatedOpp.fetch("Paperwork_Sent_On_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['contract_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Contract UUID Update to Membership Agreement UUID?")
        passedLogs = @objRollbar.addLog("[Expected] Contract UUID= #{membershipAgreementUUID}")
        expect(updatedOpp.fetch("Contract_UUID__c")).to eq membershipAgreementUUID
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Contract Stage Update to Contract Sent?") 
        passedLogs = @objRollbar.addLog("[Expected] Contract Stage= Contract Sent") 
        expect(updatedOpp.fetch("Contract_Stage__c")).to eq "Contract Sent"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Paperwork Sent By Update to Contact Id?") 
        passedLogs = @objRollbar.addLog("[Expected] Paperwork Sent By=#{@recordCreated['contact'][1].fetch("Id")}") 
        expect(updatedOpp.fetch("Send_Paperwork_By__c")).to eq @recordCreated['contact'][1].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Actual Start Date Update to Start Date?") 
        passedLogs = @objRollbar.addLog("[Expected] Actual Start Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date']}") 
        expect(updatedOpp.fetch("Actual_Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Reserved Update to Moveins Quantity?") 
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Reserved=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity']}")
        expect(updatedOpp.fetch("Total_Desks_Reserved__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Moveout Should Update to Moveouts Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Move out=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity']}")
        expect(updatedOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Reserved(net) Update With Difference Between Opportunity Move ins and Opportunity Move Outs?")
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Reserved(Net)=#{(@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i)-(@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)}")
        expect(updatedOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks Update to Sum of Quantity of Product?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity']}")
        expect(updatedOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Gross) Update to Product Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks(Gross)=#{@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity']}")
        expect(updatedOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Original Contract UUID Update to Membership Agreement UUID?")
        passedLogs = @objRollbar.addLog("[Expected] Original Contract UUID= ")
        expect(updatedOpp.fetch("Original_Contract_UUID__c")).to eq ""
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Stage Update to Closing?")
        passedLogs = @objRollbar.addLog("[Expected] Stage Name= Closing")
        expect(updatedOpp.fetch("StageName")).to eq "Closing"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Building Update to Move ins Building Passing through Payload?")
        passedLogs = @objRollbar.addLog("[Expected] Building=#{@recordCreated['building'][0].fetch("Id")}")
        expect(updatedOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Move out Building Update to Building from Which Move Out Occured?")
        passedLogs = @objRollbar.addLog("[Expected] Move out Building=#{@recordCreated['building'][0].fetch("Id")}")
        expect(updatedOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Unweighted) Update?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks(Unweighted)=#{(@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i) - (@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)}")
        expect(updatedOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Weighted) Update?")
        weightedDesk = (updatedOpp.fetch("No_of_Desks_unweighted__c").to_f * (updatedOpp.fetch("Probability").to_f / 100.to_f).to_f).round
        passedlogs = @objRollbar.addLog("[Expected] No of Desks(Weighted)=#{weightedDesk}")
        expect(updatedOpp.fetch("No_of_Desks_weighted__c").to_i).to eq weightedDesk
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Contract type Update to Upgrade?")
        passedLogs = @objRollbar.addLog("[Expected] Contract Type= Upgrade")
        expect(updatedOpp.fetch("Contract_Type__c")).to eq "Upgrade"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Reservables")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Reservable not null?")
        expect(updatedOppReservable.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"


        passedLogs = @objRollbar.addLog("[Validate] Does Pending desks in Opportunity Reservables Update to Move ins Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Pending Desks in Opportunity reservable=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity']}")
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Start date in Opportunity Reservable Update With Move ins Start Date?")
        passedLogs = @objRollbar.addLog("[Expected] Start Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date']}")
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        
        passedLogs = @objRollbar.addLog("[Validate] Does Monthly Price on Opportunity Reservable update to Move ins price?")
        passedLogs = @objRollbar.addLog("[Expected] Monthly Price=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price']}")
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Move Outs")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Move Outs not null?")
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Pending Desks in Opportunity Move outs update With Move outs Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Pending Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity']}")
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Move out Date in Opportunity Move out Update?")
        passedLogs = @objRollbar.addLog("[Expected] Move out Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date']}")
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        puts "------------------------------------------------------------------------------------------------------------------"
        
        passedLogs = @objRollbar.addLog("[Step    ] Adding result in TestRail")
        @testRailUtility.postResult(862, "pass", 1, @run)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        @testRailUtility.postResult(862, "pass", 1, @run)
        rescue Exception => e
        passedLogs = @objRollbar.addLog("[Result  ] Failed")
        @objRollbar.postRollbarData(caseInfo['id'], caseInfo['title'], passedLogs[caseInfo['id']])
        Rollbar.error(e)
        @testRailUtility.postResult(862, e, 5, @run)
        raise e
      end
    end

    #********************************upgrade****************************************
    #********************************downgrade****************************************

    it 'C:905 In Downgrade event, To check if the membership_agreement_uuid matched with the existing membership_agreement_uuid while hitting payload then existing opportunity should be updated.', :'905' => true do
      begin
        caseInfo = @testRailUtility.getCase('905')
        puts 'C:905 In Downgrade event, To check if the membership_agreement_uuid matched with the existing membership_agreement_uuid while hitting payload then existing opportunity should be updated.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = contractUUID
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Name:'#{@testData['ContractEvent']['Account'][1]['name']}', Stage:'Closing', Building:'#{@testData['ContractEvent']['Building__c'][0]['Name']}', Contract UUID:'#{contractUUID}'", caseInfo['id'])
        @opportunity = @contractEvent.createOpportunity(1, 'Closing', 0, contractUUID, nil)
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        @mapOpportunityId["opportunity"] = @opportunity
        
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Membership Agreement UUID'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", nil, companyUUID, membershipAgreementUUID, nil, 1, 0, "Downgrade").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
        expect(@getResponse['success']).to be true
        expect(@getResponse['result']).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected] Payload is successfully created and hitted")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        #puts "get only id from responce"
        id = @getResponse['result'].split(':')[1].chomp('"').delete(' ')
        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Update after hitting Payload?")
        expect(id).to eq  @opportunity[0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully updated")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        updatedOpp = @contractEvent.getOpportunityDetails(id)
        passedLogs = @objRollbar.addLog("[Step    ] Fetching Updated Opportunity details")
        expect(updatedOpp.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity fields are successfully fetched")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        puts "Checking Opportunity should not null..."
        
        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details")
        updatedOppReservable = @contractEvent.getOppReservableDetails(updatedOpp.fetch("Id"))
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Move Outs details")
        updatedOppMoveOuts = @contractEvent.getOppMoveOutsDetails(updatedOpp.fetch("Id"))
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Move Outs fields are successfully fetched")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Fields")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Paperwork Sent On Date Update to Contract Date?")
        passedLogs = @objRollbar.addLog("[Expected] Paperwork sent on Date= '#{@testData['ContractEvent']['Scenarios'][0]['body']['contract_date']}'")
        expect(updatedOpp.fetch("Paperwork_Sent_On_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['contract_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Contract UUID Update to Membership Agreement UUID?")
        passedLogs = @objRollbar.addLog("[Expected] Contract UUID= #{membershipAgreementUUID}")
        expect(updatedOpp.fetch("Contract_UUID__c")).to eq membershipAgreementUUID
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Contract Stage Update to Contract Sent?") 
        passedLogs = @objRollbar.addLog("[Expected] Contract Stage= Contract Sent") 
        expect(updatedOpp.fetch("Contract_Stage__c")).to eq "Contract Sent"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Paperwork Sent By Update to Contact Id?") 
        passedLogs = @objRollbar.addLog("[Expected] Paperwork Sent By=#{@recordCreated['contact'][1].fetch("Id")}") 
        expect(updatedOpp.fetch("Send_Paperwork_By__c")).to eq @recordCreated['contact'][1].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Actual Start Date Update to Start Date?") 
        passedLogs = @objRollbar.addLog("[Expected] Actual Start Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date']}") 
        expect(updatedOpp.fetch("Actual_Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Reserved Update to Moveins Quantity?") 
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Reserved=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity']}")
        expect(updatedOpp.fetch("Total_Desks_Reserved__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i
        puts updatedOpp.fetch("Total_Desks_Reserved__c")
        puts 
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Moveout Should Update to Moveouts Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Move out=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity']}")
        expect(updatedOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Reserved(net) Update With Difference Between Opportunity Move ins and Opportunity Move Outs?")
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Reserved(Net)=#{(@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i)-(@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)}")
        expect(updatedOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)
        puts updatedOpp.fetch("Total_Desks_Reserved_net__c")
        puts (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i) 
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks Update to Sum of Quantity of Product?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity']}")
        expect(updatedOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Gross) Update to Product Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks(Gross)=#{@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity']}")
        expect(updatedOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Original Contract UUID Update to Membership Agreement UUID?")
        passedLogs = @objRollbar.addLog("[Expected] Original Contract UUID=#{membershipAgreementUUID}")
        expect(updatedOpp.fetch("Original_Contract_UUID__c")).to eq membershipAgreementUUID
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Stage Update to Closing?")
        passedLogs = @objRollbar.addLog("[Expected] Stage Name= Closing")
        expect(updatedOpp.fetch("StageName")).to eq "Closing"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Building Update to Move ins Building Passing through Payload?")
        passedLogs = @objRollbar.addLog("[Expected] Building=#{@recordCreated['building'][0].fetch("Id")}")
        expect(updatedOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Move out Building Update to Building from Which Move Out Occured?")
        passedLogs = @objRollbar.addLog("[Expected] Move out Building=#{@recordCreated['building'][0].fetch("Id")}")
        expect(updatedOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Unweighted) Update?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks(Unweighted)=#{(@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i) - (@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)}")
        expect(updatedOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - 0)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Weighted) Update?")
        weightedDesk = (updatedOpp.fetch("No_of_Desks_unweighted__c").to_f * (updatedOpp.fetch("Probability").to_f / 100.to_f).to_f).round
        passedlogs = @objRollbar.addLog("[Expected] No of Desks(Weighted)=#{weightedDesk}")
        expect(updatedOpp.fetch("No_of_Desks_weighted__c").to_i).to eq weightedDesk
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Contract type Update to Downgrade?")
        passedLogs = @objRollbar.addLog("[Expected] Contract Type= Downgrade")
        expect(updatedOpp.fetch("Contract_Type__c")).to eq "Downgrade"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Reservables")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Reservable not null?")
        expect(updatedOppReservable.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Pending desks in Opportunity Reservables Update to Move ins Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Pending Desks in Opportunity reservable=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity']}")
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        
        passedLogs = @objRollbar.addLog("[Validate] Does Start date in Opportunity Reservable Update With Move ins Start Date?")
        passedLogs = @objRollbar.addLog("[Expected] Start Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date']}")
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Monthly Price on Opportunity Reservable update to Move ins price?")
        passedLogs = @objRollbar.addLog("[Expected] Monthly Price=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price']}")
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Move Outs")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Move Outs not null?")
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Pending Desks in Opportunity Move outs update With Move outs Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Pending Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity']}")
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Move out Date in Opportunity Move out Update?")
        passedLogs = @objRollbar.addLog("[Expected] Move out Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date']}")
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        puts "------------------------------------------------------------------------------------------------------------------"
        
        passedLogs = @objRollbar.addLog("[Step    ] Adding result in TestRail")
        @testRailUtility.postResult(905, "pass", 1, @run)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        @testRailUtility.postResult(905, "pass", 1, @run)
      rescue Exception => e
        passedLogs = @objRollbar.addLog("[Result  ] Failed")
        @objRollbar.postRollbarData(caseInfo['id'], caseInfo['title'], passedLogs[caseInfo['id']])
        Rollbar.error(e)
        @testRailUtility.postResult(905, e, 5, @run)
        raise e
      end
    end

    it 'C:903 In Downgrade event, To check if opportunity id in the payload is matched with the opportunity_id in the system after hitting payload then existing opportunity in the system will be updated.', :'903' => true do
      begin
        caseInfo = @testRailUtility.getCase('903')
        puts 'C:903 In Downgrade event, To check if opportunity id in the payload is matched with the opportunity_id in the system after hitting payload then existing opportunity in the system will be updated.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Name:'#{@testData['ContractEvent']['Account'][1]['name']}', Stage:'Selling', Building:'#{@testData['ContractEvent']['Building__c'][0]['Name']}'", caseInfo['id'])
        @opportunity = @contractEvent.createOpportunity(1, "selling", 0, nil, nil)
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        @mapOpportunityId["opportunity"] = @opportunity
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Opportunity ID'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", @opportunity[0].fetch("Id"), companyUUID, membershipAgreementUUID, nil, 1, 0, "Downgrade").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
        expect(@getResponse['success']).to be true
        expect(@getResponse['result']).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected] Payload is successfully created and hitted")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        id = @getResponse['result'].split(':')[1].chomp('"').delete(' ')
        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Update after hitting Payload?")
        expect(id).to eq  @opportunity[0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully updated")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        updatedOpp = @contractEvent.getOpportunityDetails(id)
        passedLogs = @objRollbar.addLog("[Step    ] Fetching Updated Opportunity details")
        expect(updatedOpp.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity fields are successfully fetched")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details")
        updatedOppReservable = @contractEvent.getOppReservableDetails(updatedOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Move Outs details")
        updatedOppMoveOuts = @contractEvent.getOppMoveOutsDetails(updatedOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Move Outs fields are successfully fetched")
        passedLogs =@objRollbar.addLog(" [Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Fields")
        puts "\n"
        

        passedLogs = @objRollbar.addLog("[Validate] Does Paperwork Sent On Date Update to Contract Date?")
        passedLogs = @objRollbar.addLog("[Expected] Paperwork sent on Date= '#{@testData['ContractEvent']['Scenarios'][0]['body']['contract_date']}'")
        expect(updatedOpp.fetch("Paperwork_Sent_On_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['contract_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Contract UUID Update to Membership Agreement UUID?")
        passedLogs = @objRollbar.addLog("[Expected] Contract UUID= #{membershipAgreementUUID}")
        expect(updatedOpp.fetch("Contract_UUID__c")).to eq membershipAgreementUUID
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Contract Stage Update to Contract Sent?") 
        passedLogs = @objRollbar.addLog("[Expected] Contract Stage= Contract Sent") 
        expect(updatedOpp.fetch("Contract_Stage__c")).to eq "Contract Sent"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Paperwork Sent By Update to Contact Id?") 
        passedLogs = @objRollbar.addLog("[Expected] Paperwork Sent By=#{@recordCreated['contact'][1].fetch("Id")}") 
        expect(updatedOpp.fetch("Send_Paperwork_By__c")).to eq @recordCreated['contact'][1].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Actual Start Date Update to Start Date?") 
        passedLogs = @objRollbar.addLog("[Expected] Actual Start Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date']}") 
        expect(updatedOpp.fetch("Actual_Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Reserved Update to Moveins Quantity?") 
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Reserved=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity']}")
        expect(updatedOpp.fetch("Total_Desks_Reserved__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Moveout Should Update to Moveouts Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Move out=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity']}")
        expect(updatedOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Reserved(net) Update With Difference Between Opportunity Move ins and Opportunity Move Outs?")
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Reserved(Net)=#{(@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i)-(@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)}")
        expect(updatedOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks Update to Sum of Quantity of Product?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity']}")
        expect(updatedOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Gross) Update to Product Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks(Gross)=#{@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity']}")
        expect(updatedOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Original Contract UUID Update to Membership Agreement UUID?")
        passedLogs = @objRollbar.addLog("[Expected] Original Contract UUID= ")
        expect(updatedOpp.fetch("Original_Contract_UUID__c")).to eq ""
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Stage Update to Closing?")
        passedLogs = @objRollbar.addLog("[Expected] Stage Name= Closing")
        expect(updatedOpp.fetch("StageName")).to eq "Closing"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Building Update to Move ins Building Passing through Payload?")
        passedLogs = @objRollbar.addLog("[Expected] Building=#{@recordCreated['building'][0].fetch("Id")}")
        #puts  updatedOpp.fetch("Building__c")
        expect(updatedOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Move out Building Update to Building from Which Move Out Occured?")
        passedLogs = @objRollbar.addLog("[Expected] Move out Building=#{@recordCreated['building'][0].fetch("Id")}")
        #puts updatedOpp.fetch("Move_Out_Building__c")
        expect(updatedOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Unweighted) Update?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks(Unweighted)=#{(@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - 0)}")
        expect(updatedOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - 0)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Weighted) Update?")
        weightedDesk = (updatedOpp.fetch("No_of_Desks_unweighted__c").to_f * (updatedOpp.fetch("Probability").to_f / 100.to_f).to_f).round
        passedlogs = @objRollbar.addLog("[Expected] No of Desks(Weighted)=#{weightedDesk}")
        expect(updatedOpp.fetch("No_of_Desks_weighted__c").to_i).to eq weightedDesk
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Contract type Update to Downgrade?")
        passedLogs = @objRollbar.addLog("[Expected] Contract Type= Downgrade")
        expect(updatedOpp.fetch("Contract_Type__c")).to eq "Downgrade"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Reservables")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Reservable not null?")
        expect(updatedOppReservable.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Pending desks in Opportunity Reservables Update to Move ins Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Pending Desks in Opportunity reservable=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity']}")
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Start date in Opportunity Reservable Update With Move ins Start Date?")
        passedLogs = @objRollbar.addLog("[Expected] Start Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date']}")
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Monthly Price on Opportunity Reservable update to Move ins price?")
        passedLogs = @objRollbar.addLog("[Expected] Monthly Price=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price']}")
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Move Outs")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Move Outs not null?")
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Pending Desks in Opportunity Move outs update With Move outs Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Pending Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity']}")
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Move out Date in Opportunity Move out Update?")
        passedLogs = @objRollbar.addLog("[Expected] Move out Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date']}")
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        puts "------------------------------------------------------------------------------------------------------------------"
        
        passedLogs = @objRollbar.addLog("[Step    ] Adding result in TestRail")
        @testRailUtility.postResult(903, "pass", 1, @run)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        @testRailUtility.postResult(903, "pass", 1, @run)
        rescue Exception => e
        passedLogs = @objRollbar.addLog("[Result  ] Failed")
        @objRollbar.postRollbarData(caseInfo['id'], caseInfo['title'], passedLogs[caseInfo['id']])
        Rollbar.error(e)
        @testRailUtility.postResult(903, e, 5, @run)
        raise e
      end
    end

    it 'C:907 In Downgrade event, To check if company_uuid in the payload matched with the existing account in the system, there are having open opportunities after hitting payload if building matched with the existing open opportunity then existing opportunity should be updated.', :'907' => true do
      begin
        caseInfo = @testRailUtility.getCase('907')
        puts 'C:907 In Downgrade event, To check if company_uuid in the payload matched with the existing account in the system, there are having open opportunities after hitting payload if building matched with the existing open opportunity then existing opportunity should be updated.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Name:'#{@testData['ContractEvent']['Account'][1]['name']}', Stage:'Selling', Building:'#{@testData['ContractEvent']['Building__c'][0]['Name']}'", caseInfo['id'])
        @opportunity1 = @contractEvent.createOpportunity(1, "selling", 0, nil)
        expect(@opportunity1).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Name:'#{@testData['ContractEvent']['Account'][1]['name']}', Stage:'Selling', Building:'#{@testData['ContractEvent']['Building__c'][1]['Name']}'")
        @opportunity2 = @contractEvent.createOpportunity(1, "selling", 1, nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity2).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
       
        @mapOpportunityId["opportunity"] = @opportunity1
        @mapOpportunityId["opportunity"] << @opportunity2

        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Company UUID'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", nil, "#{@testData['ContractEvent']['Account'][1]['UUID__c']}", membershipAgreementUUID, nil, 1, 0, "Downgrade").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
        expect(@getResponse['success']).to be true
        expect(@getResponse['result']).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected] Payload is successfully created and hitted")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        id = @getResponse['result'].split(':')[1].chomp('"').delete(' ')
        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Update after hitting Payload?")
        expect(id).to eq  @opportunity1[0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully updated")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        updatedOpp = @contractEvent.getOpportunityDetails(id)
        passedLogs = @objRollbar.addLog("[Step    ] Fetching Updated Opportunity details")
        expect(updatedOpp.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity fields are successfully fetched")
        passedLogs =@objRollbar.addLog(" [Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details")
        updatedOppReservable = @contractEvent.getOppReservableDetails(updatedOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Move Outs details")
        updatedOppMoveOuts = @contractEvent.getOppMoveOutsDetails(updatedOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Move Outs fields are successfully fetched")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Fields")
        puts "\n"
        

        passedLogs = @objRollbar.addLog("[Validate] Does Paperwork Sent On Date Update to Contract Date?")
        passedLogs = @objRollbar.addLog("[Expected] Paperwork sent on Date= '#{@testData['ContractEvent']['Scenarios'][0]['body']['contract_date']}'")
        expect(updatedOpp.fetch("Paperwork_Sent_On_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['contract_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Contract UUID Update to Membership Agreement UUID?")
        passedLogs = @objRollbar.addLog("[Expected] Contract UUID= #{membershipAgreementUUID}")
        expect(updatedOpp.fetch("Contract_UUID__c")).to eq membershipAgreementUUID
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Contract Stage Update to Contract Sent?") 
        passedLogs = @objRollbar.addLog("[Expected] Contract Stage= Contract Sent") 
        expect(updatedOpp.fetch("Contract_Stage__c")).to eq "Contract Sent"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Paperwork Sent By Update to Contact Id?") 
        passedLogs = @objRollbar.addLog("[Expected] Paperwork Sent By=#{@recordCreated['contact'][1].fetch("Id")}") 
        expect(updatedOpp.fetch("Send_Paperwork_By__c")).to eq @recordCreated['contact'][1].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Actual Start Date Update to Start Date?") 
        passedLogs = @objRollbar.addLog("[Expected] Actual Start Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date']}") 
        expect(updatedOpp.fetch("Actual_Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Reserved Update to Moveins Quantity?") 
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Reserved=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity']}")
        expect(updatedOpp.fetch("Total_Desks_Reserved__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Moveout Should Update to Moveouts Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Move out=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity']}")
        expect(updatedOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Reserved(net) Update With Difference Between Opportunity Move ins and Opportunity Move Outs?")
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Reserved(Net)=#{(@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i)-(@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)}")
        expect(updatedOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks Update to Sum of Quantity of Product?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity']}")
        expect(updatedOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Gross) Update to Product Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks(Gross)=#{@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity']}")
        expect(updatedOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Original Contract UUID Update to Membership Agreement UUID?")
        passedLogs = @objRollbar.addLog("[Expected] Original Contract UUID= ")
        expect(updatedOpp.fetch("Original_Contract_UUID__c")).to eq ""
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Stage Update to Closing?")
        passedLogs = @objRollbar.addLog("[Expected] Stage Name= Closing")
        expect(updatedOpp.fetch("StageName")).to eq "Closing"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Building Update to Move ins Building Passing through Payload?")
        passedLogs = @objRollbar.addLog("[Expected] Building=#{@recordCreated['building'][0].fetch("Id")}")
        expect(updatedOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Move out Building Update to Building from Which Move Out Occured?")
        passedLogs = @objRollbar.addLog("[Expected] Move out Building=#{@recordCreated['building'][0].fetch("Id")}")
        expect(updatedOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Unweighted) Update?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks(Unweighted)=#{(@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i) - (@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)}")
        expect(updatedOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - 0)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Weighted) Update?")
        weightedDesk = (updatedOpp.fetch("No_of_Desks_unweighted__c").to_f * (updatedOpp.fetch("Probability").to_f / 100.to_f).to_f).round
        passedlogs = @objRollbar.addLog("[Expected] No of Desks(Weighted)=#{weightedDesk}")
        expect(updatedOpp.fetch("No_of_Desks_weighted__c").to_i).to eq weightedDesk
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Contract type Update to Downgrade?")
        passedLogs = @objRollbar.addLog("[Expected] Contract Type= Downgrade")
        expect(updatedOpp.fetch("Contract_Type__c")).to eq "Downgrade"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Reservables")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Reservable not null?")
        expect(updatedOppReservable.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Pending desks in Opportunity Reservables Update to Move ins Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Pending Desks in Opportunity reservable=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity']}")
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Start date in Opportunity Reservable Update With Move ins Start Date?")
        passedLogs = @objRollbar.addLog("[Expected] Start Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date']}")
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Monthly Price on Opportunity Reservable update to Move ins price?")
        passedLogs = @objRollbar.addLog("[Expected] Monthly Price=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price']}")
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        
        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Move Outs")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Move Outs not null?")
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Pending Desks in Opportunity Move outs update With Move outs Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Pending Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity']}")
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Move out Date in Opportunity Move out Update?")
        passedLogs = @objRollbar.addLog("[Expected] Move out Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date']}")
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        puts "------------------------------------------------------------------------------------------------------------------"
        
        passedLogs = @objRollbar.addLog("[Step    ] Adding result in TestRail")
        @testRailUtility.postResult(907, "pass", 1, @run)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        @testRailUtility.postResult(907, "pass", 1, @run)
      rescue Exception => e
        passedLogs = @objRollbar.addLog("[Result  ] Failed")
        @objRollbar.postRollbarData(caseInfo['id'], caseInfo['title'], passedLogs[caseInfo['id']])
        Rollbar.error(e)
        @testRailUtility.postResult(907, e, 5, @run)
        raise e
      end
    end

    it 'C:908 In Downgrade event, To check if company_uuid in the payload matched with the existing account in the system, there are having open opportunities after hitting payload if building does not matched with the existing open opportunity then latest opportunity will be updated.', :'908' => true do
      begin
        caseInfo = @testRailUtility.getCase('908')
        puts 'C:908 In Downgrade event, To check if company_uuid in the payload matched with the existing account in the system, there are having open opportunities after hitting payload if building does not matched with the existing open opportunity then latest opportunity will be updated.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        
        #@contractEvent.createOpportunity(stageName = nil, buildingNumber = nil ,contractUUID = nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Name:'#{@testData['ContractEvent']['Account'][1]['name']}', Stage:'Selling', Building:'#{@testData['ContractEvent']['Building__c'][1]['Name']}'", caseInfo['id'])
        @opportunity1 = @contractEvent.createOpportunity(1, "selling", 1, nil)
        expect(@opportunity1).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Name:'#{@testData['ContractEvent']['Account'][1]['name']}', Stage:'Selling', Building:'#{@testData['ContractEvent']['Building__c'][2]['Name']}'")
        @opportunity2 = @contractEvent.createOpportunity(1, "selling", 2, nil)
        expect(@opportunity2).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        

        @mapOpportunityId["opportunity"] = @opportunity1
        @mapOpportunityId["opportunity"] << @opportunity2

        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Company UUID'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", nil, "#{@testData['ContractEvent']['Account'][1]['UUID__c']}", membershipAgreementUUID, nil, 1, 0, "Downgrade").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
        expect(@getResponse['success']).to be true
        expect(@getResponse['result']).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected] Payload is successfully created and hitted")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        id = @getResponse['result'].split(':')[1].chomp('"').delete(' ')
        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Update after hitting Payload?")
        expect(id).to eq  @opportunity2[0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully updated")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        updatedOpp = @contractEvent.getOpportunityDetails(id)
        passedLogs = @objRollbar.addLog("[Step    ] Fetching Updated Opportunity details")
        expect(updatedOpp.fetch("Id")).to eq @opportunity2[0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Expected] Opportunity fields are successfully fetched")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details")
        updatedOppReservable = @contractEvent.getOppReservableDetails(updatedOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Move Outs details")
        updatedOppMoveOuts = @contractEvent.getOppMoveOutsDetails(updatedOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Move Outs fields are successfully fetched")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Fields")
        puts "\n"
        

        passedLogs = @objRollbar.addLog("[Validate] Does Paperwork Sent On Date Update to Contract Date?")
        passedLogs = @objRollbar.addLog("[Expected] Paperwork sent on Date= '#{@testData['ContractEvent']['Scenarios'][0]['body']['contract_date']}'")
        expect(updatedOpp.fetch("Paperwork_Sent_On_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['contract_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Contract UUID Update to Membership Agreement UUID?")
        passedLogs = @objRollbar.addLog("[Expected] Contract UUID= #{membershipAgreementUUID}")
        expect(updatedOpp.fetch("Contract_UUID__c")).to eq membershipAgreementUUID
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Contract Stage Update to Contract Sent?") 
        passedLogs = @objRollbar.addLog("[Expected] Contract Stage= Contract Sent") 
        expect(updatedOpp.fetch("Contract_Stage__c")).to eq "Contract Sent"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Paperwork Sent By Update to Contact Id?") 
        passedLogs = @objRollbar.addLog("[Expected] Paperwork Sent By=#{@recordCreated['contact'][1].fetch("Id")}") 
        expect(updatedOpp.fetch("Send_Paperwork_By__c")).to eq @recordCreated['contact'][1].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Actual Start Date Update to Start Date?") 
        passedLogs = @objRollbar.addLog("[Expected] Actual Start Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date']}") 
        expect(updatedOpp.fetch("Actual_Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Reserved Update to Moveins Quantity?") 
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Reserved=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity']}")
        expect(updatedOpp.fetch("Total_Desks_Reserved__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Moveout Should Update to Moveouts Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Move out=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity']}")
        expect(updatedOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Reserved(net) Update With Difference Between Opportunity Move ins and Opportunity Move Outs?")
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Reserved(Net)=#{(@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i)-(@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)}")
        expect(updatedOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks Update to Sum of Quantity of Product?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity']}")
        expect(updatedOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Gross) Update to Product Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks(Gross)=#{@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity']}")
        expect(updatedOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Original Contract UUID Update to Membership Agreement UUID?")
        passedLogs = @objRollbar.addLog("[Expected] Original Contract UUID= ")
        expect(updatedOpp.fetch("Original_Contract_UUID__c")).to eq ""
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Stage Update to Closing?")
        passedLogs = @objRollbar.addLog("[Expected] Stage Name= Closing")
        expect(updatedOpp.fetch("StageName")).to eq "Closing"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Building Update to Move ins Building Passing through Payload?")
        passedLogs = @objRollbar.addLog("[Expected] Building=#{@recordCreated['building'][0].fetch("Id")}")
        expect(updatedOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Move out Building Update to Building from Which Move Out Occured?")
        passedLogs = @objRollbar.addLog("[Expected] Move out Building=#{@recordCreated['building'][0].fetch("Id")}")
        expect(updatedOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Unweighted) Update?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks(Unweighted)=#{(@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - 0)}")
        expect(updatedOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - 0)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Weighted) Update?")
        weightedDesk = (updatedOpp.fetch("No_of_Desks_unweighted__c").to_f * (updatedOpp.fetch("Probability").to_f / 100.to_f).to_f).round
        passedlogs = @objRollbar.addLog("[Expected] No of Desks(Weighted)=#{weightedDesk}")
        expect(updatedOpp.fetch("No_of_Desks_weighted__c").to_i).to eq weightedDesk
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Contract type Update to Downgrade?")
        passedLogs = @objRollbar.addLog("[Expected] Contract Type= Downgrade")
        expect(updatedOpp.fetch("Contract_Type__c")).to eq "Downgrade"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Reservables")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Reservable not null?")
        expect(updatedOppReservable.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Pending desks in Opportunity Reservables Update to Move ins Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Pending Desks in Opportunity reservable=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity']}")
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Start date in Opportunity Reservable Update With Move ins Start Date?")
        passedLogs = @objRollbar.addLog("[Expected] Start Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date']}")
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Monthly Price on Opportunity Reservable update to Move ins price?")
        passedLogs = @objRollbar.addLog("[Expected] Monthly Price=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price']}")
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Move Outs")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Move Outs not null?")
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Pending Desks in Opportunity Move outs update With Move outs Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Pending Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity']}")
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Move out Date in Opportunity Move out Update?")
        passedLogs = @objRollbar.addLog("[Expected] Move out Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date']}")
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        
        passedLogs = @objRollbar.addLog("[Step    ] Adding result in TestRail")
        @testRailUtility.postResult(908, "pass", 1, @run)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        
        @testRailUtility.postResult(908, "pass", 1, @run)
      rescue Exception => e
        passedLogs = @objRollbar.addLog("[Result  ] Failed")
        @objRollbar.postRollbarData(caseInfo['id'], caseInfo['title'], passedLogs[caseInfo['id']])
        Rollbar.error(e)
        @testRailUtility.postResult(908, e, 5, @run)
        raise e
      end
    end

    it 'C:909 In Downgrade event, To check if company_uuid matched with the existing opportunity and for that account there is having opportunity with the stages closed won or closed lost, while hitting payload for a particular building then new opportunity should be created.', :'909' => true do
      begin
        caseInfo = @testRailUtility.getCase('909')
        puts 'C:909 In Downgrade event, To check if company_uuid matched with the existing opportunity and for that account there is having opportunity with the stages closed won or closed lost, while hitting payload for a particular building then new opportunity should be created.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        #@contractEvent.createOpportunity(stageName = nil, buildingNumber = nil ,contractUUID = nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Name:'#{@testData['ContractEvent']['Account'][1]['name']}', Stage:'Closed Won', Building:'#{@testData['ContractEvent']['Building__c'][1]['Name']},Contract UUID:'#{contractUUID}'",caseInfo['id'])
        @opportunity1 = @contractEvent.createOpportunity(1, "Closed Won", 1, contractUUID)
        expect(@opportunity1).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Name:'#{@testData['ContractEvent']['Account'][1]['name']}', Stage:'Closed Lost', Building:'#{@testData['ContractEvent']['Building__c'][2]['Name']}")
        @opportunity2 = @contractEvent.createOpportunity(1, "Closed Lost", 2, nil)
        expect(@opportunity2).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        
        @mapOpportunityId["opportunity"] = @opportunity1
        @mapOpportunityId["opportunity"] << @opportunity2
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Membership Agreement UUID'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", nil, "#{@testData['ContractEvent']['Account'][1]['UUID__c']}", membershipAgreementUUID, nil, 1, 0, "Downgrade").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
        expect(@getResponse['success']).to be true
        expect(@getResponse['result']).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected] Payload is successfully created and hitted")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        id = @getResponse['result'].split(':')[1].chomp('"').delete(' ')
        passedLogs = @objRollbar.addLog("[Validate] Does New Opportunity created after hitting Payload?")
        createdOpp = @contractEvent.getOpportunityDetails(id)
        expect(createdOpp.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        @mapOpportunityId["opportunity"] << Hash["Id" => id]

        createdOpp = @contractEvent.getOpportunityDetails(id)
        Salesforce.addRecordsToDelete('Opportunity',id)
        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details")
        updatedOppReservable = @contractEvent.getOppReservableDetails(createdOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs =@objRollbar.addLog("[Result   ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Move Outs details")
        updatedOppMoveOuts = @contractEvent.getOppMoveOutsDetails(createdOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Move Outs fields are successfully fetched")
        passedLogs =@objRollbar.addLog(" [Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Fields")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Paperwork Sent On Date Update to Contract Date?")
        passedLogs = @objRollbar.addLog("[Expected] Paperwork sent on Date= '#{@testData['ContractEvent']['Scenarios'][0]['body']['contract_date']}'")
        expect(createdOpp.fetch("Paperwork_Sent_On_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['contract_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Contract UUID Update to Membership Agreement UUID?")
        passedLogs = @objRollbar.addLog("[Expected] Contract UUID= #{membershipAgreementUUID}")
        expect(createdOpp.fetch("Contract_UUID__c")).to eq membershipAgreementUUID
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Contract Stage Update to Contract Sent?") 
        passedLogs = @objRollbar.addLog("[Expected] Contract Stage= Contract Sent") 
        expect(createdOpp.fetch("Contract_Stage__c")).to eq "Contract Sent"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Paperwork Sent By Update to Contact Id?") 
        passedLogs = @objRollbar.addLog("[Expected] Paperwork Sent By=#{@recordCreated['contact'][1].fetch("Id")}") 
        expect(createdOpp.fetch("Send_Paperwork_By__c")).to eq @recordCreated['contact'][1].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Actual Start Date Update to Start Date?") 
        passedLogs = @objRollbar.addLog("[Expected] Actual Start Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date']}") 
        expect(createdOpp.fetch("Actual_Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Reserved Update to Moveins Quantity?") 
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Reserved=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity']}")
        expect(createdOpp.fetch("Total_Desks_Reserved__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Moveout Should Update to Moveouts Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Move out=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity']}")
        expect(createdOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Reserved(net) Update With Difference Between Opportunity Move ins and Opportunity Move Outs?")
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Reserved(Net)=#{(@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i)-(@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)}")
        expect(createdOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks Update to Sum of Quantity of Product?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity']}")
        expect(createdOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Gross) Update to Product Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks(Gross)=#{@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity']}")
        expect(createdOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Original Contract UUID Update to Membership Agreement UUID?")
        passedLogs = @objRollbar.addLog("[Expected] Original Contract UUID= ")
        expect(createdOpp.fetch("Original_Contract_UUID__c")).to eq ""
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Stage Update to Closing?")
        passedLogs = @objRollbar.addLog("[Expected] Stage Name= Closing")
        expect(createdOpp.fetch("StageName")).to eq "Closing"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Building Update to Move ins Building Passing through Payload?")
        passedLogs = @objRollbar.addLog("[Expected] Building=#{@recordCreated['building'][0].fetch("Id")}")
        expect(createdOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Move out Building Update to Building from Which Move Out Occured?")
        passedLogs = @objRollbar.addLog("[Expected] Move out Building=#{@recordCreated['building'][0].fetch("Id")}")
        expect(createdOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Close date updated to One month forward?")
        d = Date.today
        passedLogs = @objRollbar.addLog("[Expected] Close Date=#{(d + 30).to_s}")
        expect(createdOpp.fetch("CloseDate")).to eq (d + 30).to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Owner Update?")
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Owner=#{@config['Staging']['username']}")
        expect(createdOpp.fetch("Owner.Username")).to eq @config['Staging']['username']
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Unweighted) Update?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks(Unweighted)=#{(@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - 0)}")
        expect(createdOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - 0)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Weighted) Update?")
        weightedDesk = (createdOpp.fetch("No_of_Desks_unweighted__c").to_f * (createdOpp.fetch("Probability").to_f / 100.to_f).to_f).round
        passedlogs = @objRollbar.addLog("[Expected] No of Desks(Weighted)=#{weightedDesk}")
        expect(createdOpp.fetch("No_of_Desks_weighted__c").to_i).to eq weightedDesk
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Contract type Update to Downgrade?")
        passedLogs = @objRollbar.addLog("[Expected] Contract Type= Downgrade")
        expect(createdOpp.fetch("Contract_Type__c")).to eq "Downgrade"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Reservables")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Reservable not null?")
        expect(updatedOppReservable.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Pending desks in Opportunity Reservables Update to Move ins Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Pending Desks in Opportunity reservable=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity']}")
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Start date in Opportunity Reservable Update With Move ins Start Date?")
        passedLogs = @objRollbar.addLog("[Expected] Start Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date']}")
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Monthly Price on Opportunity Reservable update to Move ins price?")
        passedLogs = @objRollbar.addLog("[Expected] Monthly Price=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price']}")
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        
        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Move Outs")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Move Outs not null?")
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Pending Desks in Opportunity Move outs update With Move outs Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Pending Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity']}")
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Move out Date in Opportunity Move out Update?")
        passedLogs = @objRollbar.addLog("[Expected] Move out Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date']}")
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

         puts "------------------------------------------------------------------------------------------------------------------"
        
        passedLogs = @objRollbar.addLog("[Step    ] Adding result in TestRail")
        @testRailUtility.postResult(909, "pass", 1, @run)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        @testRailUtility.postResult(909, "pass", 1, @run)
      rescue Exception => e
        passedLogs = @objRollbar.addLog("[Result  ] Failed")
        @objRollbar.postRollbarData(caseInfo['id'], caseInfo['title'], passedLogs[caseInfo['id']])
        Rollbar.error(e)
        @testRailUtility.postResult(909, e, 5, @run)
        raise e
      end
    end

    it 'C:911 In Downgrade event, To check if the company_uuid matched with the existing opportunity and for that account there is having opportunity with stages closing and contract stage as sent then new opportunity should be created.', :'911' => true do
      begin
        caseInfo = @testRailUtility.getCase('911')
        puts 'C:911 In Downgrade event, To check if the company_uuid matched with the existing opportunity and for that account there is having opportunity with stages closing and contract stage as sent then new opportunity should be created.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Name:'#{@testData['ContractEvent']['Account'][1]['name']}', Stage:'Closing', Building:'#{@testData['ContractEvent']['Building__c'][1]['Name']},Contract UUID:'#{contractUUID}', Contract Stage 'Contract Sent'",caseInfo['id'])
        @opportunity = @contractEvent.createOpportunity(1, "Closing", 1, contractUUID, "Contract Sent")
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        @mapOpportunityId["opportunity"] = @opportunity
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Company UUID'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", nil, "#{@testData['ContractEvent']['Account'][1]['UUID__c']}", membershipAgreementUUID, nil, 1, 0, "Downgrade").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
        expect(@getResponse['success']).to be true
        expect(@getResponse['result']).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected] Payload is successfully created and hitted")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        id = @getResponse['result'].split(':')[1].chomp('"').delete(' ')
        passedLogs = @objRollbar.addLog("[Validate] Does New Opportunity created after hitting Payload?")
        createdOpp = @contractEvent.getOpportunityDetails(id)
        Salesforce.addRecordsToDelete('Opportunity',id)
        expect(createdOpp.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        @mapOpportunityId["opportunity"] << Hash["Id" => id]

        createdOpp = @contractEvent.getOpportunityDetails(id)
        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details")
        updatedOppReservable = @contractEvent.getOppReservableDetails(createdOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs =@objRollbar.addLog("[Result   ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Move Outs details")
        updatedOppMoveOuts = @contractEvent.getOppMoveOutsDetails(createdOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Move Outs fields are successfully fetched")
        passedLogs =@objRollbar.addLog(" [Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Fields")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Paperwork Sent On Date Update to Contract Date?")
        passedLogs = @objRollbar.addLog("[Expected] Paperwork sent on Date= '#{@testData['ContractEvent']['Scenarios'][0]['body']['contract_date']}'")
        expect(createdOpp.fetch("Paperwork_Sent_On_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['contract_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Contract UUID Update to Membership Agreement UUID?")
        passedLogs = @objRollbar.addLog("[Expected] Contract UUID= #{membershipAgreementUUID}")
        expect(createdOpp.fetch("Contract_UUID__c")).to eq membershipAgreementUUID
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Contract Stage Update to Contract Sent?") 
        passedLogs = @objRollbar.addLog("[Expected] Contract Stage= Contract Sent") 
        expect(createdOpp.fetch("Contract_Stage__c")).to eq "Contract Sent"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Paperwork Sent By Update to Contact Id?") 
        passedLogs = @objRollbar.addLog("[Expected] Paperwork Sent By=#{@recordCreated['contact'][1].fetch("Id")}") 
        expect(createdOpp.fetch("Send_Paperwork_By__c")).to eq @recordCreated['contact'][1].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Actual Start Date Update to Start Date?") 
        passedLogs = @objRollbar.addLog("[Expected] Actual Start Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date']}") 
        expect(createdOpp.fetch("Actual_Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Reserved Update to Moveins Quantity?") 
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Reserved=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity']}")
        expect(createdOpp.fetch("Total_Desks_Reserved__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Moveout Should Update to Moveouts Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Move out=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity']}")
        expect(createdOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Reserved(net) Update With Difference Between Opportunity Move ins and Opportunity Move Outs?")
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Reserved(Net)=#{(@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i)-(@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)}")
        expect(createdOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks Update to Sum of Quantity of Product?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity']}")
        expect(createdOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Gross) Update to Product Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks(Gross)=#{@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity']}")
        expect(createdOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Original Contract UUID Update to Membership Agreement UUID?")
        passedLogs = @objRollbar.addLog("[Expected] Original Contract UUID=''")
        expect(createdOpp.fetch("Original_Contract_UUID__c")).to eq ""
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Stage Update to Closing?")
        passedLogs = @objRollbar.addLog("[Expected] Stage Name= Closing")
        expect(createdOpp.fetch("StageName")).to eq "Closing"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Building Update to Move ins Building Passing through Payload?")
        passedLogs = @objRollbar.addLog("[Expected] Building=#{@recordCreated['building'][0].fetch("Id")}")
        expect(createdOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Move out Building Update to Building from Which Move Out Occured?")
        passedLogs = @objRollbar.addLog("[Expected] Move out Building=#{@recordCreated['building'][0].fetch("Id")}")
        expect(createdOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Close date updated to One monthe forward?")
        d = Date.today
        passedLogs = @objRollbar.addLog("[Expected] Close Date=#{(d + 30).to_s}")
        expect(createdOpp.fetch("CloseDate")).to eq (d + 30).to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Owner Update?")
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Owner=#{@config['Staging']['username']}")
        expect(createdOpp.fetch("Owner.Username")).to eq @config['Staging']['username']
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Unweighted) Update?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks(Unweighted)=#{(@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - 0)}")
        expect(createdOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - 0)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Weighted) Update?")
        weightedDesk = (createdOpp.fetch("No_of_Desks_unweighted__c").to_f * (createdOpp.fetch("Probability").to_f / 100.to_f).to_f).round
        passedlogs = @objRollbar.addLog("[Expected] No of Desks(Weighted)=#{weightedDesk}")
        expect(createdOpp.fetch("No_of_Desks_weighted__c").to_i).to eq weightedDesk
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Contract type Update to Downgrade?")
        passedLogs = @objRollbar.addLog("[Expected] Contract Type= Downgrade")
        expect(createdOpp.fetch("Contract_Type__c")).to eq "Downgrade"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Reservables")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Reservable not null?")
        expect(updatedOppReservable.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Pending desks in Opportunity Reservables Update to Move ins Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Pending Desks in Opportunity reservable=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity']}")
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Start date in Opportunity Reservable Update With Move ins Start Date?")
        passedLogs = @objRollbar.addLog("[Expected] Start Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date']}")
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Monthly Price on Opportunity Reservable update to Move ins price?")
        passedLogs = @objRollbar.addLog("[Expected] Monthly Price=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price']}")
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Move Outs")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Move Outs not null?")
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Pending Desks in Opportunity Move outs update With Move outs Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Pending Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity']}")
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Move out Date in Opportunity Move out Update?")
        passedLogs = @objRollbar.addLog("[Expected] Move out Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date']}")
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        puts "------------------------------------------------------------------------------------------------------------------"
        
        passedLogs = @objRollbar.addLog("[Step    ] Adding result in TestRail")
        @testRailUtility.postResult(911, "pass", 1, @run)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        @testRailUtility.postResult(911, "pass", 1, @run)
      rescue Exception => e
        passedLogs = @objRollbar.addLog("[Result  ] Failed")
        @objRollbar.postRollbarData(caseInfo['id'], caseInfo['title'], passedLogs[caseInfo['id']])
        Rollbar.error(e)
        @testRailUtility.postResult(911, e, 5, @run)
        raise e
      end
    end

    it 'C:912 In Downgrade event, To check if the opportunity stage is closing but the contract stage is blank or other than contract sent or signed then new opportunity Should not be created.', :'912' => true do
      begin
        caseInfo = @testRailUtility.getCase('912')
        puts 'C:912 In Downgrade event, To check if the opportunity stage is closing but the contract stage is blank or other than contract sent or signed then new opportunity Should not be created.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Name:'#{@testData['ContractEvent']['Account'][1]['name']}', Stage:'Closing', Building:'#{@testData['ContractEvent']['Building__c'][1]['Name']},Contract UUID:'#{contractUUID}', Contract Stage 'Contract Discarded'",caseInfo['id'])
        @opportunity = @contractEvent.createOpportunity(1, "Closing", 1, contractUUID, "Contract Discarded")
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        
        @mapOpportunityId["opportunity"] = @opportunity
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Company UUID'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", nil, "#{@testData['ContractEvent']['Account'][1]['UUID__c']}", membershipAgreementUUID, nil, 1, 0, "Downgrade").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
        expect(@getResponse['success']).to be true
        expect(@getResponse['result']).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected] Payload is successfully created and hitted")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        id = @getResponse['result'].split(':')[1].chomp('"').delete(' ')
        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Update after hitting Payload?")
        expect(id).to eq  @opportunity[0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully updated")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        updatedOpp = @contractEvent.getOpportunityDetails(id)
        passedLogs = @objRollbar.addLog("[Step    ] Fetching Updated Opportunity details")
        expect(updatedOpp.fetch("Id")).to eq @opportunity[0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Expected] Opportunity fields are successfully fetched")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details")
        updatedOppReservable = @contractEvent.getOppReservableDetails(updatedOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Move Outs details")
        updatedOppMoveOuts = @contractEvent.getOppMoveOutsDetails(updatedOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Move Outs fields are successfully fetched")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Fields")
        puts "\n"
        

        passedLogs = @objRollbar.addLog("[Validate] Does Paperwork Sent On Date Update to Contract Date?")
        passedLogs = @objRollbar.addLog("[Expected] Paperwork sent on Date= '#{@testData['ContractEvent']['Scenarios'][0]['body']['contract_date']}'")
        expect(updatedOpp.fetch("Paperwork_Sent_On_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['contract_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Contract UUID Update to Membership Agreement UUID?")
        passedLogs = @objRollbar.addLog("[Expected] Contract UUID= #{membershipAgreementUUID}")
        expect(updatedOpp.fetch("Contract_UUID__c")).to eq membershipAgreementUUID
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Contract Stage Update to Contract Sent?") 
        passedLogs = @objRollbar.addLog("[Expected] Contract Stage= Contract Sent") 
        expect(updatedOpp.fetch("Contract_Stage__c")).to eq "Contract Sent"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Paperwork Sent By Update to Contact Id?") 
        passedLogs = @objRollbar.addLog("[Expected] Paperwork Sent By=#{@recordCreated['contact'][1].fetch("Id")}") 
        expect(updatedOpp.fetch("Send_Paperwork_By__c")).to eq @recordCreated['contact'][1].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Actual Start Date Update to Start Date?") 
        passedLogs = @objRollbar.addLog("[Expected] Actual Start Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date']}") 
        expect(updatedOpp.fetch("Actual_Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Reserved Update to Moveins Quantity?") 
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Reserved=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity']}")
        expect(updatedOpp.fetch("Total_Desks_Reserved__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Moveout Should Update to Moveouts Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Move out=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity']}")
        expect(updatedOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Reserved(net) Update With Difference Between Opportunity Move ins and Opportunity Move Outs?")
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Reserved(Net)=#{(@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i)-(@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)}")
        expect(updatedOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks Update to Sum of Quantity of Product?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity']}")
        expect(updatedOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Gross) Update to Product Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks(Gross)=#{@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity']}")
        expect(updatedOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Original Contract UUID Update to Membership Agreement UUID?")
        passedLogs = @objRollbar.addLog("[Expected] Original Contract UUID= ")
        expect(updatedOpp.fetch("Original_Contract_UUID__c")).to eq ""
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Stage Update to Closing?")
        passedLogs = @objRollbar.addLog("[Expected] Stage Name= Closing")
        expect(updatedOpp.fetch("StageName")).to eq "Closing"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Building Update to Move ins Building Passing through Payload?")
        passedLogs = @objRollbar.addLog("[Expected] Building=#{@recordCreated['building'][0].fetch("Id")}")
        expect(updatedOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Move out Building Update to Building from Which Move Out Occured?")
        passedLogs = @objRollbar.addLog("[Expected] Move out Building=#{@recordCreated['building'][0].fetch("Id")}")
        expect(updatedOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Unweighted) Update?")
        passedLogs = @objRollbar.addLog("[Expected] No of Desks(Unweighted)=#{(@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - 0)}")
        expect(updatedOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - 0)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does No of Desks(Weighted) Update?")
        weightedDesk = (updatedOpp.fetch("No_of_Desks_unweighted__c").to_f * (updatedOpp.fetch("Probability").to_f / 100.to_f).to_f).round
        passedlogs = @objRollbar.addLog("[Expected] No of Desks(Weighted)=#{weightedDesk}")
        expect(updatedOpp.fetch("No_of_Desks_weighted__c").to_i).to eq weightedDesk
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Contract type Update to Downgrade?")
        passedLogs = @objRollbar.addLog("[Expected] Contract Type= Downgrade")
        expect(updatedOpp.fetch("Contract_Type__c")).to eq "Upgrade"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Reservables")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Reservable not null?")
        expect(updatedOppReservable.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Pending desks in Opportunity Reservables Update to Move ins Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Pending Desks in Opportunity reservable=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity']}")
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Start date in Opportunity Reservable Update With Move ins Start Date?")
        passedLogs = @objRollbar.addLog("[Expected] Start Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date']}")
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Monthly Price on Opportunity Reservable update to Move ins price?")
        passedLogs = @objRollbar.addLog("[Expected] Monthly Price=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price']}")
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Checking Updated Opportunity Move Outs")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Opportunity Move Outs not null?")
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Pending Desks in Opportunity Move outs update With Move outs Quantity?")
        passedLogs = @objRollbar.addLog("[Expected] Pending Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity']}")
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Validate] Does Move out Date in Opportunity Move out Update?")
        passedLogs = @objRollbar.addLog("[Expected] Move out Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date']}")
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        puts "------------------------------------------------------------------------------------------------------------------"
        
        passedLogs = @objRollbar.addLog("[Step    ] Adding result in TestRail")
        @testRailUtility.postResult(912, "pass", 1, @run)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        @testRailUtility.postResult(912, "pass", 1, @run)
      rescue Exception => e
        passedLogs = @objRollbar.addLog("[Result  ] Failed")
        @objRollbar.postRollbarData(caseInfo['id'], caseInfo['title'], passedLogs[caseInfo['id']])
        Rollbar.error(e)
        @testRailUtility.postResult(912, e, 5, @run)
        raise e
      end
    end

    #********************************downgrade****************************************
    

    after(:each) {
      if @mapOpportunityId != nil then
        passedLogs = @objRollbar.addLog("[Step    ] Deleting Opportunity Test Data")
        #puts @mapOpportunityId['opportunity']
        @contractEvent.deleteCreatedOpportunities(@mapOpportunityId['opportunity'])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Test Data should be deleted.")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
      end
     
    }
  end

  after(:all) {
    puts ""
    puts "------------------------------------------------------------------------------------------------------------------"

    passedLogs = @objRollbar.addLog("[Step    ] Deleting Test Data")
    @contractEvent.deleteCreatedRecord()
    passedLogs = @objRollbar.addLog("[Expected] Test Data should be deleted.")
    passedLogs = @objRollbar.addLog("[Result  ] Success")
    puts "\n"
    
    puts "------------------------------------------------------------------------------------------------------------------"
  }
  after(:each) {
    puts ""
    puts "------------------------------------------------------------------------------------------------------------------"
  }
end

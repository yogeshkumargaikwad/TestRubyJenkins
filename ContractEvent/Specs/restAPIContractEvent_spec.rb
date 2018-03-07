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
        puts 'C:452 In Upgrade event, To check if opportunity id in the payload is matched with the opportunity_id in the system after hitting payload then existing opportunity in the system will be updated.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        @opportunity = @contractEvent.createOpportunity(1, "selling", 0, nil, nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        @mapOpportunityId["opportunity"] = @opportunity
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Membership Agreement UUID'")
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

        updatedOpp = @contractEvent.getOpportunityDetails(id)
        passedLogs = @objRollbar.addLog("[Step    ] Fetching Updated Opportunity details")
        expect(updatedOpp.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity fields are successfully fetched")
        passedLogs =@objRollbar.addLog(" [Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details")
        updatedOppReservable = @contractEvent.getOppReservableDetails(updatedOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs =@objRollbar.addLog("[Result   ] Success")
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

        puts "[Validate] Should Total Desks Moveout should Updated With Moveouts Quantity?"
        puts "[Expected] Total Desks Move outs=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity']}"
        expect(updatedOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should Total Desks Reserved(Net) Updated With Difference Between Opportunity Move ins and Opportunity Move outs?"
        puts "[Expected] Total Desks Reserved(Net)=#{(@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i) - (@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)}"
        expect(updatedOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
 

        puts "[Validate] Should No of Desks Updated with Sum of Quantity of Product?"
        puts "[Expected] No of Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity']}"
        expect(updatedOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] No of Desks(Gross) Should Updated With Product Quantity?"
        puts "[Expected] No of Desks(Gross)=#{@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity']}"
        expect(updatedOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should Original Contract UUID Updated With Membership Agreement UUID?"
        puts "[Expected] Original Contract UUID= "
        expect(updatedOpp.fetch("Original_Contract_UUID__c")).to eq ""
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should Opportunity Stage Updated to Closing?"
        puts "[Expected] Stage Name= Closing"
        expect(updatedOpp.fetch("StageName")).to eq "Closing"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should Opportunity Building Updated With Move ins Building Passing through Payload?"
        puts "[Expected] Building=#{@recordCreated['building'][0].fetch("Id")}"
        #puts  updatedOpp.fetch("Building__c")
        expect(updatedOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should Move out Building Updated to Building from Which Move Out Occured?"
        #puts updatedOpp.fetch("Move_Out_Building__c")
        puts "[Expected] Move out Building=#{@recordCreated['building'][0].fetch("Id")}"
        expect(updatedOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should No of Desks(Unweighted) Updated?"
        puts "[expected] No of Desks(Unweighted)=#{(@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i) - (@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)}"
        expect(updatedOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should No of Desks(Weighted) Updated?"
        weightedDesk = (updatedOpp.fetch("No_of_Desks_unweighted__c").to_f * (updatedOpp.fetch("Probability").to_f / 100.to_f).to_f).round
        puts "[Expected] No of Desks(Weighted)=#{weightedDesk}"
        expect(updatedOpp.fetch("No_of_Desks_weighted__c").to_i).to eq weightedDesk
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should Contract type Updated With Upgrade?"
        puts "[Expected] Contract Type= Upgrade"
        expect(updatedOpp.fetch("Contract_Type__c")).to eq "Upgrade"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "******************************************************************************************"
        puts "Checking Updated Opportunity Reservables"

        puts "Checking Opportunity Reservable Should Not Null..."
        expect(updatedOppReservable.fetch("Id")).not_to eq nil

        puts "[Validate] Should Pending desks in Opportunity Reservables Updated With Move ins Quantity?"
        puts "[Expected] Pending Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity']}"
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 


        puts "[Validate] Should Start date in Opportunity Reservable Updated With Move ins Start Date?"
        puts "[Expected] Start Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date']}"
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should Monthly Price on Opportunity Reservable Updated With Move ins Price?"
        puts "[Expected] Monthly Price=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price']}"
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "******************************************************************************************"
        puts "Checking Updated Opportunity Move Outs"

        puts "Checking Opportunity Move Outs Should not null..."
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil

        puts "[Validate] Should Pending Desks in Opportunity Move Outs Updated With Move Outs Quantity?"
        puts "[Expected] Pending Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity']}"
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should Move Out Date in Opportunity Move Out Updated?"
        puts "[Expected] Move out Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date']}"
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "******************************************************************************************"

        @testRailUtility.postResult(452, "pass", 1, @run)
      rescue Exception => e
        puts "[Result  ] Failed"
        @testRailUtility.postResult(452, e, 5, @run)
        raise e
      end
    end

    it 'C:453 In Upgrade event, To check if company_uuid in the payload matched with the existing account in the system, there are having open opportunities after hitting payload if building matched with the existing open opportunity then existing opportunity should be updated.', :'453' => true do
      begin
        puts 'C:453 In Upgrade event, To check if company_uuid in the payload matched with the existing account in the system, there are having open opportunities after hitting payload if building matched with the existing open opportunity then existing opportunity should be updated.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        
        
        @opportunity1 = @contractEvent.createOpportunity(1, "selling", 0, nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity1}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity1).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        @opportunity2 = @contractEvent.createOpportunity(1, "selling", 1, nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity2}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity2).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        @mapOpportunityId["opportunity"] = @opportunity1
        @mapOpportunityId["opportunity"] << @opportunity2[0]
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Membership Agreement UUID'")
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
        expect(updatedOpp.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity fields are successfully fetched")
        passedLogs =@objRollbar.addLog(" [Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details")
        updatedOppReservable = @contractEvent.getOppReservableDetails(updatedOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs =@objRollbar.addLog(" [Result  ] Success")
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

        puts "[Validate] Should Total Desks Moveout should updated with Moveouts quantity?"
        puts "[expected] Total Desks Move out=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity']}"
        expect(updatedOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should Total Desks Reserved(net) updated with difference between Opportunity Move ins and Opportunity Move outs?"
        puts "[expected] Total Desks Reserved(net)=#{(@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i)-(@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)}"
        expect(updatedOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should No of Desks updated with Sum of quantity of Product?"
        puts "[expected] No of Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity']}"
        expect(updatedOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] No of Desks(Gross) should updated with Product Quantity?"
        puts "[expected] No of Desks(Gross)=#{@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity']}"
        expect(updatedOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should Original Contract UUID updated with Membership Agreement UUID?"
        puts "[expected] original Contract UUID= "
        expect(updatedOpp.fetch("Original_Contract_UUID__c")).to eq ""
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should Opportunity Stage updated to Closing?"
        puts "[expected] Stage Name= Closing"
        expect(updatedOpp.fetch("StageName")).to eq "Closing"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should Opportunity Building updated with move ins Building passing through payload?"
        puts "[expected] Building=#{@recordCreated['building'][0].fetch("Id")}"
        expect(updatedOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should Move out Building updated to Building from which move out occured?"
        puts "[expected] Move out Building=#{@recordCreated['building'][0].fetch("Id")}"
        expect(updatedOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should No of Desks(Unweighted) updated?"
        puts "[expected] No of Desks(Unweighted)=#{(@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i)- (@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)}"
        expect(updatedOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "Checking Opportunity- No. of Desks (weighted)..."
        expect(updatedOpp.fetch("No_of_Desks_weighted__c").to_i).to eq (updatedOpp.fetch("No_of_Desks_unweighted__c").to_f * (updatedOpp.fetch("Probability").to_f / 100.to_f).to_f).round

        puts "[Validate] Should Contract type updated with Upgrade?"
        puts "[expected] Contract Type= Upgrade"
        expect(updatedOpp.fetch("Contract_Type__c")).to eq "Upgrade"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "**************************************************************************"
        puts "Checking Updated Opportunity Reservables"

        puts "Checking OppReservable should not null..."
        expect(updatedOppReservable.fetch("Id")).not_to eq nil

        puts "[Validate] Should Pending desks in Opportunity Reservables updated with Move ins Quantity?"
        puts "[expected] Pending Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity']}"
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should Start date in Opportunity Reservable updated with Move ins Start Date?"
        puts "[expected] Start Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date']}"
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should Monthly price on Opportunity Reservable updated with Move ins price?"
        puts "[expected] Monthly Price=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price']}"
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 
    
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Move Outs"

        puts "Checking Opportunity Move Outs should not null..."
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil

        puts "[Validate] Should Pending Desks in Opportunity Move outs updated with Move outs Quantity?"
        puts "[expected] Pending Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity']}"
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should Move out date in Opportunity Move out updated?"
        puts "[expected] Move out Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date']}"
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "**************************************************************************"

        @testRailUtility.postResult(453, "pass", 1, @run)
      rescue Exception => e
        puts "[result] Failed"
        @testRailUtility.postResult(453, e, 5, @run)
        raise e
      end
    end

    it 'C:726 In Upgrade event, To check if company_uuid in the payload matched with the existing account in the system, there are having open opportunities after hitting payload if building does not matched with the existing open opportunity then latest opportunity will be updated.', :'726' => true do
      begin
        puts 'C:726 In Upgrade event, To check if company_uuid in the payload matched with the existing account in the system, there are having open opportunities after hitting payload if building does not matched with the existing open opportunity then latest opportunity will be updated.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        
        #@contractEvent.createOpportunity(stageName = nil, buildingNumber = nil ,contractUUID = nil)
        @opportunity1 = @contractEvent.createOpportunity(1, "selling", 1, nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        @opportunity2 = @contractEvent.createOpportunity(1, "selling", 2, nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        @mapOpportunityId["opportunity"] = @opportunity1
        @mapOpportunityId["opportunity"] << @opportunity2[0]

        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Membership Agreement UUID'")
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
        expect(updatedOpp.fetch("Id")).to eq @opportunity2[0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Expected] Opportunity fields are successfully fetched")
        passedLogs =@objRollbar.addLog(" [Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details")
        updatedOppReservable = @contractEvent.getOppReservableDetails(updatedOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs =@objRollbar.addLog("[Result   ] Success")
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

        puts "[Validate] Should Total Desks Moveout should updated with Moveouts quantity?"
        puts "[expected] Total Desks Moveout=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity']}"
        expect(updatedOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should Total Desks Reserved(net) updated with difference between Opportunity Move ins and Opportunity Move outs?"
        puts "[expected] Total Desks Reserved(net)=#{(@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i)-(@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)}"
        expect(updatedOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should No of Desks updated with Sum of quantity of Product?"
        puts "[expected] No of Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity']}"
        expect(updatedOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] No of Desks(Gross) should updated with Product Quantity?"
        puts "[expected] No of Desks(Gross)=#{@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity']}"
        expect(updatedOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should Original Contract UUID updated with Membership Agreement UUID?"
        puts "[expected] Original Contract UUID= "
        expect(updatedOpp.fetch("Original_Contract_UUID__c")).to eq ""
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should Opportunity Stage updated to Closing?"
        puts "[expected] Stage Name= Closing"
        expect(updatedOpp.fetch("StageName")).to eq "Closing"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should Opportunity Building updated with move ins Building passing through payload?"
        puts "[expected] Building=#{@recordCreated['building'][0].fetch("Id")}"
        expect(updatedOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should Move out Building updated to Building from which move out occured?"
        puts "[expected] Move out Building=#{@recordCreated['building'][0].fetch("Id")}"
        expect(updatedOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should No of Desks(Unweighted) updated?"
        puts "[expected] No of Desks(Unweighted)= #{(@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i)-(@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)}"
        expect(updatedOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "Checking Opportunity- No. of Desks (weighted)..."
        expect(updatedOpp.fetch("No_of_Desks_weighted__c").to_i).to eq (updatedOpp.fetch("No_of_Desks_unweighted__c").to_f * (updatedOpp.fetch("Probability").to_f / 100.to_f).to_f).round

        puts "[Validate] Should Contract type updated with Upgrade?"
        puts "[expected] Contract Type= Upgrade"
        expect(updatedOpp.fetch("Contract_Type__c")).to eq "Upgrade"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Reservables"

        puts "Checking OppReservable should not null..."
        expect(updatedOppReservable.fetch("Id")).not_to eq nil

        puts "[Validate] Should Pending desks in Opportunity Reservables updated with Move ins Quantity?"
        puts "[expected] Pending Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity']}"
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should Start date in Opportunity Reservable updated with Move ins Start Date?"
        puts "[expected] Start Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date']}"
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should Monthly price on Opportunity Reservable updated with Move ins price?"
        puts "[expected] Monthly Price=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price']}"
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "**************************************************************************"
        puts "Checking Updated Opportunity Move Outs"

        puts "Checking Opportunity Move Outs should not null..."
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil

        puts "[Validate] Should Pending Desks in Opportunity Move outs updated with Move outs Quantity?"
        puts "[expected] Pending Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity']}"
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 
        
        puts "[Validate] Should Move out date in Opportunity Move out updated?"
        puts "[expected] Move out Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date']}"
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 
        puts "**************************************************************************"

        @testRailUtility.postResult(726, "pass", 1, @run)
      rescue Exception => e
        puts "[result] Failed"
        @testRailUtility.postResult(726, e, 5, @run)
        raise e
      end
    end

    it 'C:857 In Upgrade event, To check if company_uuid matched with the existing opportunity and for that account there is having opportunity with the stages closed won or closed lost, while hitting payload for a particular building then new opportunity should be created.', :'857' => true do
      begin
        puts 'C:857 In Upgrade event, To check if company_uuid matched with the existing opportunity and for that account there is having opportunity with the stages closed won or closed lost, while hitting payload for a particular building then new opportunity should be created.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        
        
        #@contractEvent.createOpportunity(stageName = nil, buildingNumber = nil ,contractUUID = nil)
        @opportunity1 = @contractEvent.createOpportunity(1, "Closed Won", 1, contractUUID)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        @opportunity2 = @contractEvent.createOpportunity(1, "Closed Lost", 2, nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        
        @mapOpportunityId["opportunity"] = @opportunity1
        @mapOpportunityId["opportunity"] << @opportunity2[0]

        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Membership Agreement UUID'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", nil, "#{@testData['ContractEvent']['Account'][1]['UUID__c']}", membershipAgreementUUID, nil, 0, 1, "Upgrade").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
        expect(@getResponse['success']).to be true
        expect(@getResponse['result']).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected] Payload is successfully created and hitted")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        id = @getResponse['result'].split(':')[1].chomp('"').delete(' ')
        

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

        puts "Checking Opportunity should not null..."
        expect(createdOpp.fetch("Id")).not_to eq nil

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

        puts "[Validate] Should Total Desks Moveout should updated with Moveouts quantity?"
        puts "[expected] Total Desks Moveouts=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity']}"
        expect(createdOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should Total Desks Reserved(net) updated with difference between Opportunity Move ins and Opportunity Move outs?"
        puts "[expected] Total Desks Reserved(net)=#{(@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i)-(@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)}"
        expect(createdOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should No of Desks updated with Sum of quantity of Product?"
        puts "[expected] No of Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity']}"
        expect(createdOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] No of Desks(Gross) should updated with Product Quantity?"
        puts "[expected] No of Desks(Gross)=#{@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity']}"
        expect(createdOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should Original Contract UUID updated with Membership Agreement UUID?"
        puts "[expected] Original Contract UUID= "
        expect(createdOpp.fetch("Original_Contract_UUID__c")).to eq ""
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should Opportunity Stage updated to Closing?"
        puts "[expected] Stage Name= Closing"
        expect(createdOpp.fetch("StageName")).to eq "Closing"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should Opportunity Building updated with move ins Building passing through payload?"
        puts "[expected] Building=#{@recordCreated['building'][0].fetch("Id")}"
        expect(createdOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should Move out Building updated to Building from which move out occured?"
        puts "[expected] Move out Building=#{@recordCreated['building'][0].fetch("Id")}"
        expect(createdOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should Close date updated?"
        d = Date.today
        puts "[expected] Close Date=#{(d + 30).to_s}"
        expect(createdOpp.fetch("CloseDate")).to eq (d + 30).to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should Opportunity Owner Update?"
        puts "[expected] Opportunity Owner=#{@config['Staging']['username']}"
        expect(createdOpp.fetch("Owner.Username")).to eq @config['Staging']['username']
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should No of Desks(Unweighted) updated?"
        puts "[expected] No of Desks(Unweighted)=#{(@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i)-(@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)}"
        expect(createdOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "Checking Opportunity- No. of Desks (weighted)..."
        expect(createdOpp.fetch("No_of_Desks_weighted__c").to_i).to eq (createdOpp.fetch("No_of_Desks_unweighted__c").to_f * (createdOpp.fetch("Probability").to_f / 100.to_f).to_f).round

        puts "[Validate] Should Contract type updated with Upgrade?"
        puts "[expected] Contract Type= Upgrade"
        expect(createdOpp.fetch("Contract_Type__c")).to eq "Upgrade"
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 
        
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Reservables"

        puts "Checking OppReservable should not null..."
        expect(updatedOppReservable.fetch("Id")).not_to eq nil

        puts "[Validate] Should Pending desks in Opportunity Reservables updated with Move ins Quantity?"
        puts "[expected] Pending Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity']}"
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should Start date in Opportunity Reservable updated with Move ins Start Date?"
        puts "[expected] Start Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date']}"
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should Monthly price on Opportunity Reservable updated with Move ins price?"
        puts "[expected] Monthly Price=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price']}"
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 


        puts "**************************************************************************"
        puts "Checking Updated Opportunity Move Outs"

        puts "Checking Opportunity Move Outs should not null..."
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil

        puts "[Validate] Should Pending Desks in Opportunity Move outs updated with Move outs Quantity?"
        puts "[expected] Pending Desks=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity']}"
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "[Validate] Should Move out date in Opportunity Move out updated?"
        puts "[expected] Move out Date=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date']}"
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 
        puts "**************************************************************************"

        @testRailUtility.postResult(857, "pass", 1, @run)
      rescue Exception => e
        puts "[result] Failed"
        @testRailUtility.postResult(857, e, 5, @run)
        raise e
      end
    end

    it 'C:858 In Upgrade event, To check if the company_uuid matched with the existing opportunity and for that account there is having opportunity with stages closing and contract stage as sent then new opportunity should be created.', :'858' => true do
      begin
        puts 'C:858 In Upgrade event, To check if the company_uuid matched with the existing opportunity and for that account there is having opportunity with stages closing and contract stage as sent then new opportunity should be created.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        puts "Created Opportunity"

        @opportunity = @contractEvent.createOpportunity(1, "Closing", 1, contractUUID, "Contract Sent")
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        @mapOpportunityId["opportunity"] = @opportunity
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Membership Agreement UUID'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", nil, "#{@testData['ContractEvent']['Account'][1]['UUID__c']}", membershipAgreementUUID, nil, 0, 1, "Upgrade").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
        expect(@getResponse['success']).to be true
        expect(@getResponse['result']).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected] Payload is successfully created and hitted")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        id = @getResponse['result'].split(':')[1].chomp('"').delete(' ')


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

        puts "Checking Opportunity should not null..."
        expect(createdOpp.fetch("Id")).not_to eq nil

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
        expect(createdOpp.fetch("Total_Desks_Reserved__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "Checking Opportunity- Total Desks Move Outs..."
        expect(createdOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity- Total Desks Reserved(net)..."
        expect(createdOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)

        puts "Checking Opportunity- No of Desk(s)..."
        expect(createdOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- No_of_Desks_gross__c..."
        expect(createdOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- Original_Contract_UUID__c..."
        expect(createdOpp.fetch("Original_Contract_UUID__c")).to eq ""

        puts "Checking Opportunity- Stage..."
        expect(createdOpp.fetch("StageName")).to eq "Closing"

        puts "Checking Opportunity- building..."
        expect(createdOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- Move_Out_Building__c..."
        expect(createdOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- Close Date..."
        d = Date.today
        expect(createdOpp.fetch("CloseDate")).to eq (d + 30).to_s

        puts "Checking Opportunity- Owner..."
        expect(createdOpp.fetch("Owner.Username")).to eq @config['Staging']['username']

        puts "Checking Opportunity- No. of Desks (unweighted)..."
        expect(createdOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)

        puts "Checking Opportunity- No. of Desks (weighted)..."
        expect(createdOpp.fetch("No_of_Desks_weighted__c").to_i).to eq (createdOpp.fetch("No_of_Desks_unweighted__c").to_f * (createdOpp.fetch("Probability").to_f / 100.to_f).to_f).round

        puts "Checking Opportunity- Contract_Type__c..."
        expect(createdOpp.fetch("Contract_Type__c")).to eq "Upgrade"
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Reservables"

        puts "Checking OppReservable should not null..."
        expect(updatedOppReservable.fetch("Id")).not_to eq nil

        puts "Checking OppReservable- pending desk..."
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i

        puts "Checking OppReservable- start date..."
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s

        puts "Checking OppReservable- Monthly Price..."
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Move Outs"

        puts "Checking Opportunity Move Outs should not null..."
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil

        puts "Checking Opportunity Move Outs- pending desk..."
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity Move Outs- Move_Out_Date__c..."
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s

        puts "**************************************************************************"

        @testRailUtility.postResult(858, "pass", 1, @run)
      rescue Exception => e
        @testRailUtility.postResult(858, e, 5, @run)
        raise e
      end

    end

    it 'C:862 In Upgrade event, To check if the opportunity stage is closing but the contract stage is blank or other than contract sent or signed then new opportunity Should not be created.', :'862' => true do
      begin
        puts 'C:862 In Upgrade event, To check if the opportunity stage is closing but the contract stage is blank or other than contract sent or signed then new opportunity Should not be created.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        puts "Created Opportunity"

        @opportunity = @contractEvent.createOpportunity(1, "Closing", 1, contractUUID, "Contract Discarded")
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        @mapOpportunityId["opportunity"] = @opportunity
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Membership Agreement UUID'")
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
        passedLogs =@objRollbar.addLog(" [Result  ] Success")
        puts "\n"
        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details")
        updatedOppReservable = @contractEvent.getOppReservableDetails(updatedOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs =@objRollbar.addLog("[Result   ] Success")
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
        expect(updatedOpp.fetch("Total_Desks_Reserved__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "Checking Opportunity- Total Desks Move Outs..."
        expect(updatedOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity- Total Desks Reserved(net)..."
        expect(updatedOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)

        puts "Checking Opportunity- No of Desk(s)..."
        expect(updatedOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- No_of_Desks_gross__c..."
        expect(updatedOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- Original_Contract_UUID__c..."
        expect(updatedOpp.fetch("Original_Contract_UUID__c")).to eq ""

        puts "Checking Opportunity- Stage..."
        expect(updatedOpp.fetch("StageName")).to eq "Closing"

        puts "Checking Opportunity- building..."
        expect(updatedOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- Move_Out_Building__c..."
        expect(updatedOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- No. of Desks (unweighted)..."
        expect(updatedOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)

        puts "Checking Opportunity- No. of Desks (weighted)..."
        expect(updatedOpp.fetch("No_of_Desks_weighted__c").to_i).to eq (updatedOpp.fetch("No_of_Desks_unweighted__c").to_f * (updatedOpp.fetch("Probability").to_f / 100.to_f).to_f).round

        puts "Checking Opportunity- Contract_Type__c..."
        expect(updatedOpp.fetch("Contract_Type__c")).to eq "Upgrade"
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Reservables"

        puts "Checking OppReservable should not null..."
        expect(updatedOppReservable.fetch("Id")).not_to eq nil

        puts "Checking OppReservable- pending desk..."
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i

        puts "Checking OppReservable- start date..."
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s

        puts "Checking OppReservable- Monthly Price..."
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s

        puts "**************************************************************************"
        puts "Checking Updated Opportunity Move Outs"

        puts "Checking Opportunity Move Outs should not null..."
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil

        puts "Checking Opportunity Move Outs- pending desk..."
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity Move Outs- Move_Out_Date__c..."
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s

        puts "**************************************************************************"

        @testRailUtility.postResult(862, "pass", 1, @run)
      rescue Exception => e
        @testRailUtility.postResult(862, e, 5, @run)
        raise e
      end
    end

    #********************************upgrade****************************************
    #********************************downgrade****************************************

    it 'C:905 In Downgrade event, To check if the membership_agreement_uuid matched with the existing membership_agreement_uuid while hitting payload then existing opportunity should be updated.', :'905' => true do
      begin
        puts 'C:905 In Downgrade event, To check if the membership_agreement_uuid matched with the existing membership_agreement_uuid while hitting payload then existing opportunity should be updated.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = contractUUID
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        puts 'Created Opportunity'

        @opportunity = @contractEvent.createOpportunity(1, 'Closing', 0, contractUUID, nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        #puts (@opportunity == nil)
        @mapOpportunityId["opportunity"] = @opportunity
        #puts "Opportunity in HashMap"
        #puts @mapOpportunityId
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

        updatedOpp = @contractEvent.getOpportunityDetails(id)
        passedLogs = @objRollbar.addLog("[Step    ] Fetching Updated Opportunity details")
        expect(updatedOpp.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity fields are successfully fetched")
        passedLogs =@objRollbar.addLog(" [Result  ] Success")
        puts "\n"

        puts "Checking Opportunity should not null..."
        
        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details")
        updatedOppReservable = @contractEvent.getOppReservableDetails(updatedOpp.fetch("Id"))
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs =@objRollbar.addLog("[Result   ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Move Outs details")
        updatedOppMoveOuts = @contractEvent.getOppMoveOutsDetails(updatedOpp.fetch("Id"))
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
        expect(updatedOpp.fetch("Total_Desks_Reserved__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "Checking Opportunity- Total Desks Move Outs..."
        expect(updatedOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity- Total Desks Reserved(net)..."
        expect(updatedOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)

        puts "Checking Opportunity- No of Desk(s)..."
        expect(updatedOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- No_of_Desks_gross__c..."
        expect(updatedOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- Original_Contract_UUID__c..."
        expect(updatedOpp.fetch("Original_Contract_UUID__c")).to eq membershipAgreementUUID

        puts "Checking Opportunity- Stage..."
        expect(updatedOpp.fetch("StageName")).to eq "Closing"

        puts "Checking Opportunity- building..."
        expect(updatedOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- Move_Out_Building__c..."
        expect(updatedOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- No. of Desks (unweighted)..."
        expect(updatedOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - 0)

        puts "Checking Opportunity- No. of Desks (weighted)..."
        expect(updatedOpp.fetch("No_of_Desks_weighted__c").to_i).to eq (updatedOpp.fetch("No_of_Desks_unweighted__c").to_f * (updatedOpp.fetch("Probability").to_f / 100.to_f).to_f).round

        puts "Checking Opportunity- Contract_Type__c..."
        expect(updatedOpp.fetch("Contract_Type__c")).to eq "Downgrade"
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Reservables"

        puts "Checking OppReservable should not null..."
        expect(updatedOppReservable.fetch("Id")).not_to eq nil

        puts "Checking OppReservable- pending desk..."
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i

        puts "Checking OppReservable- start date..."
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s

        puts "Checking OppReservable- Monthly Price..."
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Move Outs"

        puts "Checking Opportunity Move Outs should not null..."
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil

        puts "Checking Opportunity Move Outs- pending desk..."
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity Move Outs- Move_Out_Date__c..."
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s

        puts "**************************************************************************"

        @testRailUtility.postResult(905, "pass", 1, @run)
      rescue Exception => e
        @testRailUtility.postResult(905, e, 5, @run)
        raise e
      end
    end

    it 'C:903 In Downgrade event, To check if opportunity id in the payload is matched with the opportunity_id in the system after hitting payload then existing opportunity in the system will be updated.', :'903' => true do
      begin
        puts 'C:903 In Downgrade event, To check if opportunity id in the payload is matched with the opportunity_id in the system after hitting payload then existing opportunity in the system will be updated.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        puts "Created Opportunity"
        @opportunity = @contractEvent.createOpportunity(1, "selling", 0, nil, nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        @mapOpportunityId["opportunity"] = @opportunity
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Membership Agreement UUID'")
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

        updatedOpp = @contractEvent.getOpportunityDetails(id)
        passedLogs = @objRollbar.addLog("[Step    ] Fetching Updated Opportunity details")
        expect(updatedOpp.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity fields are successfully fetched")
        passedLogs =@objRollbar.addLog(" [Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details")
        updatedOppReservable = @contractEvent.getOppReservableDetails(updatedOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs =@objRollbar.addLog("[Result   ] Success")
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
        expect(updatedOpp.fetch("Total_Desks_Reserved__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "Checking Opportunity- Total Desks Move Outs..."
        expect(updatedOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity- Total Desks Reserved(net)..."
        expect(updatedOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)

        puts "Checking Opportunity- No of Desk(s)..."
        expect(updatedOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- No_of_Desks_gross__c..."
        expect(updatedOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- Original_Contract_UUID__c..."
        expect(updatedOpp.fetch("Original_Contract_UUID__c")).to eq ""

        puts "Checking Opportunity- Stage..."
        expect(updatedOpp.fetch("StageName")).to eq "Closing"

        puts "Checking Opportunity- building..."
        #puts  updatedOpp.fetch("Building__c")
        expect(updatedOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- Move_Out_Building__c..."
        #puts updatedOpp.fetch("Move_Out_Building__c")
        expect(updatedOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- No. of Desks (unweighted)..."
        expect(updatedOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - 0)

        puts "Checking Opportunity- No. of Desks (weighted)..."
        expect(updatedOpp.fetch("No_of_Desks_weighted__c").to_i).to eq (updatedOpp.fetch("No_of_Desks_unweighted__c").to_f * (updatedOpp.fetch("Probability").to_f / 100.to_f).to_f).round

        puts "Checking Opportunity- Contract_Type__c..."
        expect(updatedOpp.fetch("Contract_Type__c")).to eq "Downgrade"

        puts "**************************************************************************"
        puts "Checking Updated Opportunity Reservables"

        puts "Checking OppReservable should not null..."
        expect(updatedOppReservable.fetch("Id")).not_to eq nil

        puts "Checking OppReservable- pending desk..."
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i

        puts "Checking OppReservable- start date..."
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s

        puts "Checking OppReservable- Monthly Price..."
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Move Outs"

        puts "Checking Opportunity Move Outs should not null..."
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil

        puts "Checking Opportunity Move Outs- pending desk..."
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity Move Outs- Move_Out_Date__c..."
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s

        puts "**************************************************************************"

        @testRailUtility.postResult(903, "pass", 1, @run)
      rescue Exception => e
        @testRailUtility.postResult(903, e, 5, @run)
        raise e
      end
    end

    it 'C:907 In Downgrade event, To check if company_uuid in the payload matched with the existing account in the system, there are having open opportunities after hitting payload if building matched with the existing open opportunity then existing opportunity should be updated.', :'907' => true do
      begin
        puts 'C:907 In Downgrade event, To check if company_uuid in the payload matched with the existing account in the system, there are having open opportunities after hitting payload if building matched with the existing open opportunity then existing opportunity should be updated.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        puts "Created Opportunity"
        @opportunity1 = @contractEvent.createOpportunity(1, "selling", 0, nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        @opportunity2 = @contractEvent.createOpportunity(1, "selling", 1, nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
       
        @mapOpportunityId["opportunity"] = @opportunity1
        @mapOpportunityId["opportunity"] << @opportunity2[0]
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Membership Agreement UUID'")
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

        updatedOpp = @contractEvent.getOpportunityDetails(id)
        passedLogs = @objRollbar.addLog("[Step    ] Fetching Updated Opportunity details")
        expect(updatedOpp.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity fields are successfully fetched")
        passedLogs =@objRollbar.addLog(" [Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details")
        updatedOppReservable = @contractEvent.getOppReservableDetails(updatedOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs =@objRollbar.addLog("[Result   ] Success")
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
        expect(updatedOpp.fetch("Total_Desks_Reserved__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "Checking Opportunity- Total Desks Move Outs..."
        expect(updatedOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity- Total Desks Reserved(net)..."
        expect(updatedOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)

        puts "Checking Opportunity- No of Desk(s)..."
        expect(updatedOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- No_of_Desks_gross__c..."
        expect(updatedOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- Original_Contract_UUID__c..."
        expect(updatedOpp.fetch("Original_Contract_UUID__c")).to eq ""

        puts "Checking Opportunity- Stage..."
        expect(updatedOpp.fetch("StageName")).to eq "Closing"

        puts "Checking Opportunity- building..."
        expect(updatedOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- Move_Out_Building__c..."
        expect(updatedOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- No. of Desks (unweighted)..."
        expect(updatedOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - 0)

        puts "Checking Opportunity- No. of Desks (weighted)..."
        expect(updatedOpp.fetch("No_of_Desks_weighted__c").to_i).to eq (updatedOpp.fetch("No_of_Desks_unweighted__c").to_f * (updatedOpp.fetch("Probability").to_f / 100.to_f).to_f).round

        puts "Checking Opportunity- Contract_Type__c..."
        expect(updatedOpp.fetch("Contract_Type__c")).to eq "Downgrade"

        puts "**************************************************************************"
        puts "Checking Updated Opportunity Reservables"

        puts "Checking OppReservable should not null..."
        expect(updatedOppReservable.fetch("Id")).not_to eq nil

        puts "Checking OppReservable- pending desk..."
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i

        puts "Checking OppReservable- start date..."
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s

        puts "Checking OppReservable- Monthly Price..."
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Move Outs"

        puts "Checking Opportunity Move Outs should not null..."
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil

        puts "Checking Opportunity Move Outs- pending desk..."
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity Move Outs- Move_Out_Date__c..."
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s

        puts "**************************************************************************"

        @testRailUtility.postResult(907, "pass", 1, @run)
      rescue Exception => e
        @testRailUtility.postResult(907, e, 5, @run)
        raise e
      end
    end

    it 'C:908 In Downgrade event, To check if company_uuid in the payload matched with the existing account in the system, there are having open opportunities after hitting payload if building does not matched with the existing open opportunity then latest opportunity will be updated.', :'908' => true do
      begin
        puts 'C:908 In Downgrade event, To check if company_uuid in the payload matched with the existing account in the system, there are having open opportunities after hitting payload if building does not matched with the existing open opportunity then latest opportunity will be updated.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        puts "Created Opportunity"
        #@contractEvent.createOpportunity(stageName = nil, buildingNumber = nil ,contractUUID = nil)
        @opportunity1 = @contractEvent.createOpportunity(1, "selling", 1, nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        @opportunity2 = @contractEvent.createOpportunity(1, "selling", 2, nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        

        @mapOpportunityId["opportunity"] = @opportunity1
        @mapOpportunityId["opportunity"] << @opportunity2[0]
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Membership Agreement UUID'")
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

        updatedOpp = @contractEvent.getOpportunityDetails(id)
        passedLogs = @objRollbar.addLog("[Step    ] Fetching Updated Opportunity details")
        expect(updatedOpp.fetch("Id")).to eq @opportunity2[0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Expected] Opportunity fields are successfully fetched")
        passedLogs =@objRollbar.addLog(" [Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details")
        updatedOppReservable = @contractEvent.getOppReservableDetails(updatedOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs =@objRollbar.addLog("[Result   ] Success")
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
        expect(updatedOpp.fetch("Total_Desks_Reserved__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "Checking Opportunity- Total Desks Move Outs..."
        expect(updatedOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity- Total Desks Reserved(net)..."
        expect(updatedOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)

        puts "Checking Opportunity- No of Desk(s)..."
        expect(updatedOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- No_of_Desks_gross__c..."
        expect(updatedOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- Original_Contract_UUID__c..."
        expect(updatedOpp.fetch("Original_Contract_UUID__c")).to eq ""

        puts "Checking Opportunity- Stage..."
        expect(updatedOpp.fetch("StageName")).to eq "Closing"

        puts "Checking Opportunity- building..."
        expect(updatedOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- Move_Out_Building__c..."
        expect(updatedOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- No. of Desks (unweighted)..."
        expect(updatedOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - 0)

        puts "Checking Opportunity- No. of Desks (weighted)..."
        expect(updatedOpp.fetch("No_of_Desks_weighted__c").to_i).to eq (updatedOpp.fetch("No_of_Desks_unweighted__c").to_f * (updatedOpp.fetch("Probability").to_f / 100.to_f).to_f).round

        puts "Checking Opportunity- Contract_Type__c..."
        expect(updatedOpp.fetch("Contract_Type__c")).to eq "Downgrade"
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Reservables"

        puts "Checking OppReservable should not null..."
        expect(updatedOppReservable.fetch("Id")).not_to eq nil

        puts "Checking OppReservable- pending desk..."
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i

        puts "Checking OppReservable- start date..."
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s

        puts "Checking OppReservable- Monthly Price..."
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Move Outs"

        puts "Checking Opportunity Move Outs should not null..."
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil

        puts "Checking Opportunity Move Outs- pending desk..."
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity Move Outs- Move_Out_Date__c..."
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s

        puts "**************************************************************************"

        @testRailUtility.postResult(908, "pass", 1, @run)
      rescue Exception => e
        @testRailUtility.postResult(908, e, 5, @run)
        raise e
      end
    end

    it 'C:909 In Downgrade event, To check if company_uuid matched with the existing opportunity and for that account there is having opportunity with the stages closed won or closed lost, while hitting payload for a particular building then new opportunity should be created.', :'909' => true do
      begin
        puts 'C:909 In Downgrade event, To check if company_uuid matched with the existing opportunity and for that account there is having opportunity with the stages closed won or closed lost, while hitting payload for a particular building then new opportunity should be created.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        puts "Created Opportunity"
        #@contractEvent.createOpportunity(stageName = nil, buildingNumber = nil ,contractUUID = nil)
        @opportunity1 = @contractEvent.createOpportunity(1, "Closed Won", 1, contractUUID)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        @opportunity2 = @contractEvent.createOpportunity(1, "Closed Lost", 2, nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        
        @mapOpportunityId["opportunity"] = @opportunity1
        @mapOpportunityId["opportunity"] << @opportunity2[0]
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Membership Agreement UUID'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", nil, "#{@testData['ContractEvent']['Account'][1]['UUID__c']}", membershipAgreementUUID, nil, 1, 0, "Downgrade").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
        expect(@getResponse['success']).to be true
        expect(@getResponse['result']).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected] Payload is successfully created and hitted")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        id = @getResponse['result'].split(':')[1].chomp('"').delete(' ')

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

        puts "Checking Opportunity should not null..."
        expect(createdOpp.fetch("Id")).not_to eq nil

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
        expect(createdOpp.fetch("Total_Desks_Reserved__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "Checking Opportunity- Total Desks Move Outs..."
        expect(createdOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity- Total Desks Reserved(net)..."
        expect(createdOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)

        puts "Checking Opportunity- No of Desk(s)..."
        expect(createdOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- No_of_Desks_gross__c..."
        expect(createdOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- Original_Contract_UUID__c..."
        expect(createdOpp.fetch("Original_Contract_UUID__c")).to eq ""

        puts "Checking Opportunity- Stage..."
        expect(createdOpp.fetch("StageName")).to eq "Closing"

        puts "Checking Opportunity- building..."
        expect(createdOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- Move_Out_Building__c..."
        expect(createdOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- Close Date..."
        d = Date.today
        expect(createdOpp.fetch("CloseDate")).to eq (d + 30).to_s

        puts "Checking Opportunity- Owner..."
        expect(createdOpp.fetch("Owner.Username")).to eq @config['Staging']['username']

        puts "Checking Opportunity- No. of Desks (unweighted)..."
        expect(createdOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - 0)

        puts "Checking Opportunity- No. of Desks (weighted)..."
        expect(createdOpp.fetch("No_of_Desks_weighted__c").to_i).to eq (createdOpp.fetch("No_of_Desks_unweighted__c").to_f * (createdOpp.fetch("Probability").to_f / 100.to_f).to_f).round

        puts "Checking Opportunity- Contract_Type__c..."
        expect(createdOpp.fetch("Contract_Type__c")).to eq "Downgrade"
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Reservables"

        puts "Checking OppReservable should not null..."
        expect(updatedOppReservable.fetch("Id")).not_to eq nil

        puts "Checking OppReservable- pending desk..."
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i

        puts "Checking OppReservable- start date..."
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s

        puts "Checking OppReservable- Monthly Price..."
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Move Outs"

        puts "Checking Opportunity Move Outs should not null..."
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil

        puts "Checking Opportunity Move Outs- pending desk..."
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity Move Outs- Move_Out_Date__c..."
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s

        puts "**************************************************************************"

        @testRailUtility.postResult(909, "pass", 1, @run)
      rescue Exception => e
        @testRailUtility.postResult(909, e, 5, @run)
        raise e
      end
    end

    it 'C:911 In Downgrade event, To check if the company_uuid matched with the existing opportunity and for that account there is having opportunity with stages closing and contract stage as sent then new opportunity should be created.', :'911' => true do
      begin
        puts 'C:911 In Downgrade event, To check if the company_uuid matched with the existing opportunity and for that account there is having opportunity with stages closing and contract stage as sent then new opportunity should be created.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        puts "Created Opportunity"

        @opportunity = @contractEvent.createOpportunity(1, "Closing", 1, contractUUID, "Contract Sent")
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        

        @mapOpportunityId["opportunity"] = @opportunity
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Membership Agreement UUID'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", nil, "#{@testData['ContractEvent']['Account'][1]['UUID__c']}", membershipAgreementUUID, nil, 1, 0, "Downgrade").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
        expect(@getResponse['success']).to be true
        expect(@getResponse['result']).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected] Payload is successfully created and hitted")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        id = @getResponse['result'].split(':')[1].chomp('"').delete(' ')

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

        puts "Checking Opportunity should not null..."
        expect(createdOpp.fetch("Id")).not_to eq nil

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
        expect(createdOpp.fetch("Total_Desks_Reserved__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "Checking Opportunity- Total Desks Move Outs..."
        expect(createdOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity- Total Desks Reserved(net)..."
        expect(createdOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)

        puts "Checking Opportunity- No of Desk(s)..."
        expect(createdOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- No_of_Desks_gross__c..."
        expect(createdOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- Original_Contract_UUID__c..."
        expect(createdOpp.fetch("Original_Contract_UUID__c")).to eq ""

        puts "Checking Opportunity- Stage..."
        expect(createdOpp.fetch("StageName")).to eq "Closing"

        puts "Checking Opportunity- building..."
        expect(createdOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- Move_Out_Building__c..."
        expect(createdOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- Close Date..."
        d = Date.today
        expect(createdOpp.fetch("CloseDate")).to eq (d + 30).to_s

        puts "Checking Opportunity- Owner..."
        expect(createdOpp.fetch("Owner.Username")).to eq @config['Staging']['username']

        puts "Checking Opportunity- No. of Desks (unweighted)..."
        expect(createdOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - 0)

        puts "Checking Opportunity- No. of Desks (weighted)..."
        expect(createdOpp.fetch("No_of_Desks_weighted__c").to_i).to eq (createdOpp.fetch("No_of_Desks_unweighted__c").to_f * (createdOpp.fetch("Probability").to_f / 100.to_f).to_f).round

        puts "Checking Opportunity- Contract_Type__c..."
        expect(createdOpp.fetch("Contract_Type__c")).to eq "Downgrade"
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Reservables"

        puts "Checking OppReservable should not null..."
        expect(updatedOppReservable.fetch("Id")).not_to eq nil

        puts "Checking OppReservable- pending desk..."
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i

        puts "Checking OppReservable- start date..."
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s

        puts "Checking OppReservable- Monthly Price..."
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Move Outs"

        puts "Checking Opportunity Move Outs should not null..."
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil

        puts "Checking Opportunity Move Outs- pending desk..."
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity Move Outs- Move_Out_Date__c..."
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s

        puts "**************************************************************************"


        @testRailUtility.postResult(911, "pass", 1, @run)
      rescue Exception => e
        @testRailUtility.postResult(911, e, 5, @run)
        raise e
      end
    end

    it 'C:912 In Downgrade event, To check if the opportunity stage is closing but the contract stage is blank or other than contract sent or signed then new opportunity Should not be created.', :'912' => true do
      begin
        puts 'C:912 In Downgrade event, To check if the opportunity stage is closing but the contract stage is blank or other than contract sent or signed then new opportunity Should not be created.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        puts "Created Opportunity"

        @opportunity = @contractEvent.createOpportunity(1, "Closing", 1, contractUUID, "Contract Discarded")
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        
        @mapOpportunityId["opportunity"] = @opportunity
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Membership Agreement UUID'")
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

        updatedOpp = @contractEvent.getOpportunityDetails(id)
        passedLogs = @objRollbar.addLog("[Step    ] Fetching Updated Opportunity details")
        expect(updatedOpp.fetch("Id")).to eq @opportunity[0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Expected] Opportunity fields are successfully fetched")
        passedLogs =@objRollbar.addLog(" [Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details")
        updatedOppReservable = @contractEvent.getOppReservableDetails(updatedOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs =@objRollbar.addLog("[Result   ] Success")
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
        expect(updatedOpp.fetch("Total_Desks_Reserved__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "Checking Opportunity- Total Desks Move Outs..."
        expect(updatedOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity- Total Desks Reserved(net)..."
        expect(updatedOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)

        puts "Checking Opportunity- No of Desk(s)..."
        expect(updatedOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- No_of_Desks_gross__c..."
        expect(updatedOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- Original_Contract_UUID__c..."
        expect(updatedOpp.fetch("Original_Contract_UUID__c")).to eq ""

        puts "Checking Opportunity- Stage..."
        expect(updatedOpp.fetch("StageName")).to eq "Closing"

        puts "Checking Opportunity- building..."
        expect(updatedOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- Move_Out_Building__c..."
        expect(updatedOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- No. of Desks (unweighted)..."
        expect(updatedOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - 0)

        puts "Checking Opportunity- No. of Desks (weighted)..."
        expect(updatedOpp.fetch("No_of_Desks_weighted__c").to_i).to eq (updatedOpp.fetch("No_of_Desks_unweighted__c").to_f * (updatedOpp.fetch("Probability").to_f / 100.to_f).to_f).round

        puts "Checking Opportunity- Contract_Type__c..."
        expect(updatedOpp.fetch("Contract_Type__c")).to eq "Downgrade"
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Reservables"

        puts "Checking OppReservable should not null..."
        expect(updatedOppReservable.fetch("Id")).not_to eq nil

        puts "Checking OppReservable- pending desk..."
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i

        puts "Checking OppReservable- start date..."
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s

        puts "Checking OppReservable- Monthly Price..."
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s

        puts "**************************************************************************"
        puts "Checking Updated Opportunity Move Outs"

        puts "Checking Opportunity Move Outs should not null..."
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil

        puts "Checking Opportunity Move Outs- pending desk..."
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity Move Outs- Move_Out_Date__c..."
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s

        puts "**************************************************************************"

        @testRailUtility.postResult(912, "pass", 1, @run)
      rescue Exception => e
        @testRailUtility.postResult(912, e, 5, @run)
        raise e
      end
    end

    #********************************downgrade****************************************
    #********************************transfer****************************************

    it 'C:914 In Transfer event, To check if the membership_agreement_uuid matched with the existing membership_agreement_uuid while hitting payload then existing opportunity should be updated.', :'914' => true do
      begin
        puts 'C:914 In Transfer event, To check if the membership_agreement_uuid matched with the existing membership_agreement_uuid while hitting payload then existing opportunity should be updated.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = contractUUID
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        puts 'Created Opportunity'

        @opportunity = @contractEvent.createOpportunity(1, 'Closing', 0, contractUUID, nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        @mapOpportunityId["opportunity"] = @opportunity
        #puts "Opportunity in HashMap"
        #puts @mapOpportunityId
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Membership Agreement UUID'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", nil, companyUUID, membershipAgreementUUID, nil, 0, 2, "Transfer").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
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

        updatedOpp = @contractEvent.getOpportunityDetails(id)
        passedLogs = @objRollbar.addLog("[Step    ] Fetching Updated Opportunity details")
        expect(updatedOpp.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity fields are successfully fetched")
        passedLogs =@objRollbar.addLog(" [Result  ] Success")
        puts "\n"


        
        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details")
        updatedOppReservable = @contractEvent.getOppReservableDetails(updatedOpp.fetch("Id"))
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs =@objRollbar.addLog("[Result   ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Move Outs details")
        updatedOppMoveOuts = @contractEvent.getOppMoveOutsDetails(updatedOpp.fetch("Id"))
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
        expect(updatedOpp.fetch("Total_Desks_Reserved__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "Checking Opportunity- Total Desks Move Outs..."
        expect(updatedOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity- Total Desks Reserved(net)..."
        expect(updatedOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)

        puts "Checking Opportunity- No of Desk(s)..."
        expect(updatedOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- No_of_Desks_gross__c..."
        expect(updatedOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- Original_Contract_UUID__c..."
        expect(updatedOpp.fetch("Original_Contract_UUID__c")).to eq membershipAgreementUUID

        puts "Checking Opportunity- Stage..."
        expect(updatedOpp.fetch("StageName")).to eq "Closing"

        puts "Checking Opportunity- building..."
        expect(updatedOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- Move_Out_Building__c..."
        expect(updatedOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- No. of Desks (unweighted)..."
        expect(updatedOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - 0)

        puts "Checking Opportunity- No. of Desks (weighted)..."
        expect(updatedOpp.fetch("No_of_Desks_weighted__c").to_i).to eq (updatedOpp.fetch("No_of_Desks_unweighted__c").to_f * (updatedOpp.fetch("Probability").to_f / 100.to_f).to_f).round

        puts "Checking Opportunity- Contract_Type__c..."
        expect(updatedOpp.fetch("Contract_Type__c")).to eq "Transfer"
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Reservables"

        puts "Checking OppReservable should not null..."
        expect(updatedOppReservable.fetch("Id")).not_to eq nil

        puts "Checking OppReservable- pending desk..."
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i

        puts "Checking OppReservable- start date..."
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s

        puts "Checking OppReservable- Monthly Price..."
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Move Outs"

        puts "Checking Opportunity Move Outs should not null..."
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil

        puts "Checking Opportunity Move Outs- pending desk..."
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity Move Outs- Move_Out_Date__c..."
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s

        puts "**************************************************************************"

        @testRailUtility.postResult(914, "pass", 1, @run)
      rescue Exception => e
        @testRailUtility.postResult(914, e, 5, @run)
        raise e
      end
    end

    it 'C:913 In Transfer event, To check if opportunity id in the payload is matched with the opportunity_id in the system after hitting payload then existing opportunity in the system will be updated.', :'913' => true do
      begin
        puts 'C:913 In Transfer event, To check if opportunity id in the payload is matched with the opportunity_id in the system after hitting payload then existing opportunity in the system will be updated.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        puts "Created Opportunity"
        @opportunity = @contractEvent.createOpportunity(1, "selling", 0, nil, nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        @mapOpportunityId["opportunity"] = @opportunity
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Membership Agreement UUID'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", @opportunity[0].fetch("Id"), companyUUID, membershipAgreementUUID, nil, 0, 2, "Transfer").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
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
        expect(updatedOpp.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity fields are successfully fetched")
        passedLogs =@objRollbar.addLog(" [Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details")
        updatedOppReservable = @contractEvent.getOppReservableDetails(updatedOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs =@objRollbar.addLog("[Result   ] Success")
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
        expect(updatedOpp.fetch("Total_Desks_Reserved__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "Checking Opportunity- Total Desks Move Outs..."
        expect(updatedOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity- Total Desks Reserved(net)..."
        expect(updatedOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)

        puts "Checking Opportunity- No of Desk(s)..."
        expect(updatedOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- No_of_Desks_gross__c..."
        expect(updatedOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- Original_Contract_UUID__c..."
        expect(updatedOpp.fetch("Original_Contract_UUID__c")).to eq ""

        puts "Checking Opportunity- Stage..."
        expect(updatedOpp.fetch("StageName")).to eq "Closing"

        puts "Checking Opportunity- building..."
        #puts  updatedOpp.fetch("Building__c")
        expect(updatedOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- Move_Out_Building__c..."
        #puts updatedOpp.fetch("Move_Out_Building__c")
        expect(updatedOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- No. of Desks (unweighted)..."
        expect(updatedOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - 0)

        puts "Checking Opportunity- No. of Desks (weighted)..."
        expect(updatedOpp.fetch("No_of_Desks_weighted__c").to_i).to eq (updatedOpp.fetch("No_of_Desks_unweighted__c").to_f * (updatedOpp.fetch("Probability").to_f / 100.to_f).to_f).round

        puts "Checking Opportunity- Contract_Type__c..."
        expect(updatedOpp.fetch("Contract_Type__c")).to eq "Transfer"

        puts "**************************************************************************"
        puts "Checking Updated Opportunity Reservables"

        puts "Checking OppReservable should not null..."
        expect(updatedOppReservable.fetch("Id")).not_to eq nil

        puts "Checking OppReservable- pending desk..."
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i

        puts "Checking OppReservable- start date..."
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s

        puts "Checking OppReservable- Monthly Price..."
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Move Outs"

        puts "Checking Opportunity Move Outs should not null..."
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil

        puts "Checking Opportunity Move Outs- pending desk..."
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity Move Outs- Move_Out_Date__c..."
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s

        puts "**************************************************************************"

        @testRailUtility.postResult(913, "pass", 1, @run)
      rescue Exception => e
        @testRailUtility.postResult(913, e, 5, @run)
        raise e
      end
    end

    it 'C:915 In Transfer event, To check if company_uuid in the payload matched with the existing account in the system, there are having open opportunities after hitting payload if building matched with the existing open opportunity then existing opportunity should be updated.', :'915' => true do
      begin
        puts 'C:915 In Transfer event, To check if company_uuid in the payload matched with the existing account in the system, there are having open opportunities after hitting payload if building matched with the existing open opportunity then existing opportunity should be updated.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        puts "Created Opportunity"
        @opportunity1 = @contractEvent.createOpportunity(1, "selling", 0, nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        @opportunity2 = @contractEvent.createOpportunity(1, "selling", 1, nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
    
        @mapOpportunityId["opportunity"] = @opportunity1
        @mapOpportunityId["opportunity"] << @opportunity2[0]
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Membership Agreement UUID'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", nil, "#{@testData['ContractEvent']['Account'][1]['UUID__c']}", membershipAgreementUUID, nil, 0, 2, "Transfer").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
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
        expect(updatedOpp.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity fields are successfully fetched")
        passedLogs =@objRollbar.addLog(" [Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details")
        updatedOppReservable = @contractEvent.getOppReservableDetails(updatedOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs =@objRollbar.addLog("[Result   ] Success")
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
        expect(updatedOpp.fetch("Total_Desks_Reserved__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "Checking Opportunity- Total Desks Move Outs..."
        expect(updatedOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity- Total Desks Reserved(net)..."
        expect(updatedOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)

        puts "Checking Opportunity- No of Desk(s)..."
        expect(updatedOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- No_of_Desks_gross__c..."
        expect(updatedOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- Original_Contract_UUID__c..."
        expect(updatedOpp.fetch("Original_Contract_UUID__c")).to eq ""

        puts "Checking Opportunity- Stage..."
        expect(updatedOpp.fetch("StageName")).to eq "Closing"

        puts "Checking Opportunity- building..."
        expect(updatedOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- Move_Out_Building__c..."
        expect(updatedOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- No. of Desks (unweighted)..."
        expect(updatedOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - 0)

        puts "Checking Opportunity- No. of Desks (weighted)..."
        expect(updatedOpp.fetch("No_of_Desks_weighted__c").to_i).to eq (updatedOpp.fetch("No_of_Desks_unweighted__c").to_f * (updatedOpp.fetch("Probability").to_f / 100.to_f).to_f).round

        puts "Checking Opportunity- Contract_Type__c..."
        expect(updatedOpp.fetch("Contract_Type__c")).to eq "Transfer"

        puts "**************************************************************************"
        puts "Checking Updated Opportunity Reservables"

        puts "Checking OppReservable should not null..."
        expect(updatedOppReservable.fetch("Id")).not_to eq nil

        puts "Checking OppReservable- pending desk..."
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i

        puts "Checking OppReservable- start date..."
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s

        puts "Checking OppReservable- Monthly Price..."
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Move Outs"

        puts "Checking Opportunity Move Outs should not null..."
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil

        puts "Checking Opportunity Move Outs- pending desk..."
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity Move Outs- Move_Out_Date__c..."
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s

        puts "**************************************************************************"

        @testRailUtility.postResult(915, "pass", 1, @run)
      rescue Exception => e
        @testRailUtility.postResult(915, e, 5, @run)
        raise e
      end
    end

    it 'C:916 In Transfer event, To check if company_uuid in the payload matched with the existing account in the system, there are having open opportunities after hitting payload if building does not matched with the existing open opportunity then latest opportunity will be updated.', :'916' => true do
      begin
        puts 'C:916 In Transfer event, To check if company_uuid in the payload matched with the existing account in the system, there are having open opportunities after hitting payload if building does not matched with the existing open opportunity then latest opportunity will be updated.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        puts "Created Opportunity"
        #@contractEvent.createOpportunity(stageName = nil, buildingNumber = nil ,contractUUID = nil)
        @opportunity1 = @contractEvent.createOpportunity(1, "selling", 1, nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        @opportunity2 = @contractEvent.createOpportunity(1, "selling", 2, nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        
        @mapOpportunityId["opportunity"] = @opportunity1
        @mapOpportunityId["opportunity"] << @opportunity2[0]
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Membership Agreement UUID'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", nil, "#{@testData['ContractEvent']['Account'][1]['UUID__c']}", membershipAgreementUUID, nil, 0, 2, "Transfer").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
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
        expect(updatedOpp.fetch("Id")).to eq @opportunity2[0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Expected] Opportunity fields are successfully fetched")
        passedLogs =@objRollbar.addLog(" [Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details")
        updatedOppReservable = @contractEvent.getOppReservableDetails(updatedOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs =@objRollbar.addLog("[Result   ] Success")
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
        expect(updatedOpp.fetch("Total_Desks_Reserved__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "Checking Opportunity- Total Desks Move Outs..."
        expect(updatedOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity- Total Desks Reserved(net)..."
        expect(updatedOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)

        puts "Checking Opportunity- No of Desk(s)..."
        expect(updatedOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- No_of_Desks_gross__c..."
        expect(updatedOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- Original_Contract_UUID__c..."
        expect(updatedOpp.fetch("Original_Contract_UUID__c")).to eq ""

        puts "Checking Opportunity- Stage..."
        expect(updatedOpp.fetch("StageName")).to eq "Closing"

        puts "Checking Opportunity- building..."
        expect(updatedOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- Move_Out_Building__c..."
        expect(updatedOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- No. of Desks (unweighted)..."
        expect(updatedOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - 0)

        puts "Checking Opportunity- No. of Desks (weighted)..."
        expect(updatedOpp.fetch("No_of_Desks_weighted__c").to_i).to eq (updatedOpp.fetch("No_of_Desks_unweighted__c").to_f * (updatedOpp.fetch("Probability").to_f / 100.to_f).to_f).round

        puts "Checking Opportunity- Contract_Type__c..."
        expect(updatedOpp.fetch("Contract_Type__c")).to eq "Transfer"
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Reservables"

        puts "Checking OppReservable should not null..."
        expect(updatedOppReservable.fetch("Id")).not_to eq nil

        puts "Checking OppReservable- pending desk..."
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i

        puts "Checking OppReservable- start date..."
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s

        puts "Checking OppReservable- Monthly Price..."
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Move Outs"

        puts "Checking Opportunity Move Outs should not null..."
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil

        puts "Checking Opportunity Move Outs- pending desk..."
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity Move Outs- Move_Out_Date__c..."
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s

        puts "**************************************************************************"

        @testRailUtility.postResult(916, "pass", 1, @run)
      rescue Exception => e
        @testRailUtility.postResult(916, e, 5, @run)
        raise e
      end
    end

    it 'C:917 In Transfer event, To check if company_uuid matched with the existing opportunity and for that account there is having opportunity with the stages closed won or closed lost, while hitting payload for a particular building then new opportunity should be created.', :'917' => true do
      begin
        puts 'C:917 In Transfer event, To check if company_uuid matched with the existing opportunity and for that account there is having opportunity with the stages closed won or closed lost, while hitting payload for a particular building then new opportunity should be created.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        puts "Created Opportunity"
        #@contractEvent.createOpportunity(stageName = nil, buildingNumber = nil ,contractUUID = nil)
        @opportunity1 = @contractEvent.createOpportunity(1, "Closed Won", 1, contractUUID)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        @opportunity2 = @contractEvent.createOpportunity(1, "Closed Lost", 2, nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        
        @mapOpportunityId["opportunity"] = @opportunity1
        @mapOpportunityId["opportunity"] << @opportunity2[0]
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Membership Agreement UUID'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", nil, "#{@testData['ContractEvent']['Account'][1]['UUID__c']}", membershipAgreementUUID, nil, 0, 2, "Transfer").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
        expect(@getResponse['success']).to be true
        expect(@getResponse['result']).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected] Payload is successfully created and hitted")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        id = @getResponse['result'].split(':')[1].chomp('"').delete(' ')


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

        puts "Checking Opportunity should not null..."
        expect(createdOpp.fetch("Id")).not_to eq nil

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
        expect(createdOpp.fetch("Total_Desks_Reserved__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "Checking Opportunity- Total Desks Move Outs..."
        expect(createdOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity- Total Desks Reserved(net)..."
        expect(createdOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)

        puts "Checking Opportunity- No of Desk(s)..."
        expect(createdOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- No_of_Desks_gross__c..."
        expect(createdOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- Original_Contract_UUID__c..."
        expect(createdOpp.fetch("Original_Contract_UUID__c")).to eq ""

        puts "Checking Opportunity- Stage..."
        expect(createdOpp.fetch("StageName")).to eq "Closing"

        puts "Checking Opportunity- building..."
        expect(createdOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- Move_Out_Building__c..."
        expect(createdOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- Close Date..."
        d = Date.today
        expect(createdOpp.fetch("CloseDate")).to eq (d + 30).to_s

        puts "Checking Opportunity- Owner..."
        expect(createdOpp.fetch("Owner.Username")).to eq @config['Staging']['username']

        puts "Checking Opportunity- No. of Desks (unweighted)..."
        expect(createdOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - 0)

        puts "Checking Opportunity- No. of Desks (weighted)..."
        expect(createdOpp.fetch("No_of_Desks_weighted__c").to_i).to eq (createdOpp.fetch("No_of_Desks_unweighted__c").to_f * (createdOpp.fetch("Probability").to_f / 100.to_f).to_f).round

        puts "Checking Opportunity- Contract_Type__c..."
        expect(createdOpp.fetch("Contract_Type__c")).to eq "Transfer"
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Reservables"

        puts "Checking OppReservable should not null..."
        expect(updatedOppReservable.fetch("Id")).not_to eq nil

        puts "Checking OppReservable- pending desk..."
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i

        puts "Checking OppReservable- start date..."
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s

        puts "Checking OppReservable- Monthly Price..."
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Move Outs"

        puts "Checking Opportunity Move Outs should not null..."
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil

        puts "Checking Opportunity Move Outs- pending desk..."
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity Move Outs- Move_Out_Date__c..."
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s

        puts "**************************************************************************"

        @testRailUtility.postResult(917, "pass", 1, @run)
      rescue Exception => e
        @testRailUtility.postResult(917, e, 5, @run)
        raise e
      end
    end

    it 'C:918 In Transfer event, To check if the company_uuid matched with the existing opportunity and for that account there is having opportunity with stages closing and contract stage as sent then new opportunity should be created.', :'918' => true do
      begin
        puts 'C:918 In Transfer event, To check if the company_uuid matched with the existing opportunity and for that account there is having opportunity with stages closing and contract stage as sent then new opportunity should be created.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        puts "Created Opportunity"

        @opportunity = @contractEvent.createOpportunity(1, "Closing", 1, contractUUID, "Contract Sent")
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        
        @mapOpportunityId["opportunity"] = @opportunity
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Membership Agreement UUID'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", nil, "#{@testData['ContractEvent']['Account'][1]['UUID__c']}", membershipAgreementUUID, nil, 0, 2, "Transfer").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
        expect(@getResponse['success']).to be true
        expect(@getResponse['result']).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected] Payload is successfully created and hitted")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        id = @getResponse['result'].split(':')[1].chomp('"').delete(' ')

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

        puts "Checking Opportunity should not null..."
        expect(createdOpp.fetch("Id")).not_to eq nil

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
        expect(createdOpp.fetch("Total_Desks_Reserved__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "Checking Opportunity- Total Desks Move Outs..."
        expect(createdOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity- Total Desks Reserved(net)..."
        expect(createdOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)

        puts "Checking Opportunity- No of Desk(s)..."
        expect(createdOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- No_of_Desks_gross__c..."
        expect(createdOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- Original_Contract_UUID__c..."
        expect(createdOpp.fetch("Original_Contract_UUID__c")).to eq ""

        puts "Checking Opportunity- Stage..."
        expect(createdOpp.fetch("StageName")).to eq "Closing"

        puts "Checking Opportunity- building..."
        expect(createdOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- Move_Out_Building__c..."
        expect(createdOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- Close Date..."
        d = Date.today
        expect(createdOpp.fetch("CloseDate")).to eq (d + 30).to_s

        puts "Checking Opportunity- Owner..."
        expect(createdOpp.fetch("Owner.Username")).to eq @config['Staging']['username']

        puts "Checking Opportunity- No. of Desks (unweighted)..."
        expect(createdOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - 0)

        puts "Checking Opportunity- No. of Desks (weighted)..."
        expect(createdOpp.fetch("No_of_Desks_weighted__c").to_i).to eq (createdOpp.fetch("No_of_Desks_unweighted__c").to_f * (createdOpp.fetch("Probability").to_f / 100.to_f).to_f).round

        puts "Checking Opportunity- Contract_Type__c..."
        expect(createdOpp.fetch("Contract_Type__c")).to eq "Transfer"
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Reservables"

        puts "Checking OppReservable should not null..."
        expect(updatedOppReservable.fetch("Id")).not_to eq nil

        puts "Checking OppReservable- pending desk..."
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i

        puts "Checking OppReservable- start date..."
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s

        puts "Checking OppReservable- Monthly Price..."
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Move Outs"

        puts "Checking Opportunity Move Outs should not null..."
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil

        puts "Checking Opportunity Move Outs- pending desk..."
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity Move Outs- Move_Out_Date__c..."
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s

        puts "**************************************************************************"

        @testRailUtility.postResult(918, "pass", 1, @run)
      rescue Exception => e
        @testRailUtility.postResult(918, e, 5, @run)
        raise e
      end

    end

    it 'C:919 In Transfer event, To check if the opportunity stage is closing but the contract stage is blank or other than contract sent or signed then new opportunity Should not be created.', :'919' => true do
      begin
        puts 'C:919 In Transfer event, To check if the opportunity stage is closing but the contract stage is blank or other than contract sent or signed then new opportunity Should not be created.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        puts "Created Opportunity"

        @opportunity = @contractEvent.createOpportunity(1, "Closing", 1, contractUUID, "Contract Discarded")
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        @mapOpportunityId["opportunity"] = @opportunity
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Membership Agreement UUID'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", nil, "#{@testData['ContractEvent']['Account'][1]['UUID__c']}", membershipAgreementUUID, nil, 0, 2, "Transfer").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
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
        passedLogs =@objRollbar.addLog(" [Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details")
        updatedOppReservable = @contractEvent.getOppReservableDetails(updatedOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs =@objRollbar.addLog("[Result   ] Success")
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
        expect(updatedOpp.fetch("Total_Desks_Reserved__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "Checking Opportunity- Total Desks Move Outs..."
        expect(updatedOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity- Total Desks Reserved(net)..."
        expect(updatedOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)

        puts "Checking Opportunity- No of Desk(s)..."
        expect(updatedOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- No_of_Desks_gross__c..."
        expect(updatedOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- Original_Contract_UUID__c..."
        expect(updatedOpp.fetch("Original_Contract_UUID__c")).to eq ""

        puts "Checking Opportunity- Stage..."
        expect(updatedOpp.fetch("StageName")).to eq "Closing"

        puts "Checking Opportunity- building..."
        expect(updatedOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- Move_Out_Building__c..."
        expect(updatedOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- No. of Desks (unweighted)..."
        expect(updatedOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - 0)

        puts "Checking Opportunity- No. of Desks (weighted)..."
        expect(updatedOpp.fetch("No_of_Desks_weighted__c").to_i).to eq (updatedOpp.fetch("No_of_Desks_unweighted__c").to_f * (updatedOpp.fetch("Probability").to_f / 100.to_f).to_f).round

        puts "Checking Opportunity- Contract_Type__c..."
        expect(updatedOpp.fetch("Contract_Type__c")).to eq "Transfer"
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Reservables"

        puts "Checking OppReservable should not null..."
        expect(updatedOppReservable.fetch("Id")).not_to eq nil

        puts "Checking OppReservable- pending desk..."
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i

        puts "Checking OppReservable- start date..."
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s

        puts "Checking OppReservable- Monthly Price..."
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s

        puts "**************************************************************************"
        puts "Checking Updated Opportunity Move Outs"

        puts "Checking Opportunity Move Outs should not null..."
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil

        puts "Checking Opportunity Move Outs- pending desk..."
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity Move Outs- Move_Out_Date__c..."
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s

        puts "**************************************************************************"

        @testRailUtility.postResult(919, "pass", 1, @run)
      rescue Exception => e
        @testRailUtility.postResult(919, e, 5, @run)
        raise e
      end
    end

    #********************************transfer****************************************
    #********************************drop****************************************
    it 'C:924 In Drop event, To check if the membership_agreement_uuid matched with the existing membership_agreement_uuid while hitting payload then existing opportunity should be updated.', :'924' => true do
      begin
        puts 'C:924 In Drop event, To check if the membership_agreement_uuid matched with the existing membership_agreement_uuid while hitting payload then existing opportunity should be updated.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = contractUUID
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        puts 'Created Opportunity'

        @opportunity = @contractEvent.createOpportunity(1, 'Closing', 0, contractUUID, nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        #puts (@opportunity == nil)
        @mapOpportunityId["opportunity"] = @opportunity
        #puts "Opportunity in HashMap"
        #puts @mapOpportunityId
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Membership Agreement UUID'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", nil, companyUUID, membershipAgreementUUID, nil, 0, 2, "Drop").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
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
        expect(updatedOpp.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity fields are successfully fetched")
        passedLogs =@objRollbar.addLog(" [Result  ] Success")
        puts "\n"
        
        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details")
        updatedOppReservable = @contractEvent.getOppReservableDetails(updatedOpp.fetch("Id"))
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs =@objRollbar.addLog("[Result   ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Move Outs details")
        updatedOppMoveOuts = @contractEvent.getOppMoveOutsDetails(updatedOpp.fetch("Id"))
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
        expect(updatedOpp.fetch("Actual_Start_Date__c")).to eq ""
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Reserved Update to Moveins Quantity?") 
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Reserved=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity']}")
        expect(updatedOpp.fetch("Total_Desks_Reserved__c").to_i).to eq 0
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "Checking Opportunity- Total Desks Move Outs..."
        expect(updatedOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity- Total Desks Reserved(net)..."
        expect(updatedOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (0 - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)

        puts "Checking Opportunity- No of Desk(s)..."
        expect(updatedOpp.fetch("Quantity__c").to_i).to eq 0

        puts "Checking Opportunity- No_of_Desks_gross__c..."
        expect(updatedOpp.fetch("No_of_Desks_gross__c").to_i).to eq 0

        puts "Checking Opportunity- Original_Contract_UUID__c..."
        expect(updatedOpp.fetch("Original_Contract_UUID__c")).to eq membershipAgreementUUID

        puts "Checking Opportunity- Stage..."
        expect(updatedOpp.fetch("StageName")).to eq "Closing"

        puts "Checking Opportunity- building..."
        expect(updatedOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- Move_Out_Building__c..."
        expect(updatedOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- No. of Desks (unweighted)..."
        expect(updatedOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq 0

        puts "Checking Opportunity- No. of Desks (weighted)..."
        expect(updatedOpp.fetch("No_of_Desks_weighted__c").to_i).to eq 0

        puts "Checking Opportunity- Contract_Type__c..."
        expect(updatedOpp.fetch("Contract_Type__c")).to eq "Downgrade"
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Reservables"

        puts "Checking OppReservable  null..."
        puts updatedOppReservable.class

        puts "**************************************************************************"
        puts "Checking Updated Opportunity Move Outs"

        puts "Checking Opportunity Move Outs should not null..."
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil

        puts "Checking Opportunity Move Outs- pending desk..."
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity Move Outs- Move_Out_Date__c..."
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s

        puts "**************************************************************************"

        @testRailUtility.postResult(924, "pass", 1, @run)
      rescue Exception => e
        @testRailUtility.postResult(924, e, 5, @run)
        raise e
      end
    end

    it 'C:921 In Drop event, To check if opportunity id in the payload is matched with the opportunity_id in the system after hitting payload then existing opportunity in the system will be updated.', :'921' => true do
      begin
        puts 'C:921 In Drop event, To check if opportunity id in the payload is matched with the opportunity_id in the system after hitting payload then existing opportunity in the system will be updated.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        puts "Created Opportunity"
        @opportunity = @contractEvent.createOpportunity(1, "selling", 0, nil, nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        @mapOpportunityId["opportunity"] = @opportunity
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Membership Agreement UUID'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", @opportunity[0].fetch("Id"), companyUUID, membershipAgreementUUID, nil, 0, 2, "Drop").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
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
        expect(updatedOpp.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity fields are successfully fetched")
        passedLogs =@objRollbar.addLog(" [Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details")
        updatedOppReservable = @contractEvent.getOppReservableDetails(updatedOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs =@objRollbar.addLog("[Result   ] Success")
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
        expect(updatedOpp.fetch("Actual_Start_Date__c")).to eq ""
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Reserved Update to Moveins Quantity?") 
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Reserved=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity']}")
        expect(updatedOpp.fetch("Total_Desks_Reserved__c").to_i).to eq 0
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "Checking Opportunity- Total Desks Move Outs..."
        expect(updatedOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity- Total Desks Reserved(net)..."
        expect(updatedOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (0 - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)

        puts "Checking Opportunity- No of Desk(s)..."
        expect(updatedOpp.fetch("Quantity__c").to_i).to eq 0

        puts "Checking Opportunity- No_of_Desks_gross__c..."
        expect(updatedOpp.fetch("No_of_Desks_gross__c").to_i).to eq 0

        puts "Checking Opportunity- Original_Contract_UUID__c..."
        expect(updatedOpp.fetch("Original_Contract_UUID__c")).to eq ""

        puts "Checking Opportunity- Stage..."
        expect(updatedOpp.fetch("StageName")).to eq "Closing"

        puts "Checking Opportunity- building..."
        #puts  updatedOpp.fetch("Building__c")
        expect(updatedOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- Move_Out_Building__c..."
        #puts updatedOpp.fetch("Move_Out_Building__c")
        expect(updatedOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- No. of Desks (unweighted)..."
        expect(updatedOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq 0

        puts "Checking Opportunity- No. of Desks (weighted)..."
        expect(updatedOpp.fetch("No_of_Desks_weighted__c").to_i).to eq 0

        puts "Checking Opportunity- Contract_Type__c..."
        expect(updatedOpp.fetch("Contract_Type__c")).to eq "Downgrade"

        puts "**************************************************************************"
        puts "Checking Updated Opportunity Reservables"

        puts "Checking OppReservable should null..."

        puts "**************************************************************************"
        puts "Checking Updated Opportunity Move Outs"

        puts "Checking Opportunity Move Outs should not null..."
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil

        puts "Checking Opportunity Move Outs- pending desk..."
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity Move Outs- Move_Out_Date__c..."
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s

        puts "**************************************************************************"

        @testRailUtility.postResult(921, "pass", 1, @run)
      rescue Exception => e
        @testRailUtility.postResult(921, e, 5, @run)
        raise e
      end
    end

    it 'C:927 In Drop event, To check if company_uuid in the payload matched with the existing account in the system, there are having open opportunities after hitting payload if building matched with the existing open opportunity then existing opportunity should be updated.', :'927' => true do
      begin
        puts 'C:927 In Drop event, To check if company_uuid in the payload matched with the existing account in the system, there are having open opportunities after hitting payload if building matched with the existing open opportunity then existing opportunity should be updated.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        puts "Created Opportunity"
        @opportunity1 = @contractEvent.createOpportunity(1, "selling", 0, nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        @opportunity2 = @contractEvent.createOpportunity(1, "selling", 1, nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        @mapOpportunityId["opportunity"] = @opportunity1
        @mapOpportunityId["opportunity"] << @opportunity2[0]
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Membership Agreement UUID'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", nil, "#{@testData['ContractEvent']['Account'][1]['UUID__c']}", membershipAgreementUUID, nil, 0, 2, "Drop").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
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
        expect(updatedOpp.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity fields are successfully fetched")
        passedLogs =@objRollbar.addLog(" [Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details")
        updatedOppReservable = @contractEvent.getOppReservableDetails(updatedOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs =@objRollbar.addLog("[Result   ] Success")
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
        expect(updatedOpp.fetch("Actual_Start_Date__c")).to eq ""
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Reserved Update to Moveins Quantity?") 
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Reserved=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity']}")
        expect(updatedOpp.fetch("Total_Desks_Reserved__c").to_i).to eq 0
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "Checking Opportunity- Total Desks Move Outs..."
        expect(updatedOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity- Total Desks Reserved(net)..."
        expect(updatedOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (0 - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)

        puts "Checking Opportunity- No of Desk(s)..."
        expect(updatedOpp.fetch("Quantity__c").to_i).to eq 0

        puts "Checking Opportunity- No_of_Desks_gross__c..."
        expect(updatedOpp.fetch("No_of_Desks_gross__c").to_i).to eq 0

        puts "Checking Opportunity- Original_Contract_UUID__c..."
        expect(updatedOpp.fetch("Original_Contract_UUID__c")).to eq ""

        puts "Checking Opportunity- Stage..."
        expect(updatedOpp.fetch("StageName")).to eq "Closing"

        puts "Checking Opportunity- building..."
        expect(updatedOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- Move_Out_Building__c..."
        expect(updatedOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- No. of Desks (unweighted)..."
        expect(updatedOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq 0

        puts "Checking Opportunity- No. of Desks (weighted)..."
        expect(updatedOpp.fetch("No_of_Desks_weighted__c").to_i).to eq 0

        puts "Checking Opportunity- Contract_Type__c..."
        expect(updatedOpp.fetch("Contract_Type__c")).to eq "Downgrade"

        puts "**************************************************************************"
        puts "Checking Updated Opportunity Reservables"

        puts "Checking OppReservable should null..."

        puts "**************************************************************************"
        puts "Checking Updated Opportunity Move Outs"

        puts "Checking Opportunity Move Outs should not null..."
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil

        puts "Checking Opportunity Move Outs- pending desk..."
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity Move Outs- Move_Out_Date__c..."
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s

        puts "**************************************************************************"

        @testRailUtility.postResult(927, "pass", 1, @run)
      rescue Exception => e
        @testRailUtility.postResult(927, e, 5, @run)
        raise e
      end
    end

    it 'C:930 In Drop event, To check if company_uuid in the payload matched with the existing account in the system, there are having open opportunities after hitting payload if building does not matched with the existing open opportunity then latest opportunity will be updated.', :'930' => true do
      begin
        puts 'C:930 In Drop event, To check if company_uuid in the payload matched with the existing account in the system, there are having open opportunities after hitting payload if building does not matched with the existing open opportunity then latest opportunity will be updated.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        puts "Created Opportunity"
        #@contractEvent.createOpportunity(stageName = nil, buildingNumber = nil ,contractUUID = nil)
        @opportunity1 = @contractEvent.createOpportunity(1, "selling", 1, nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        @opportunity2 = @contractEvent.createOpportunity(1, "selling", 2, nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        @mapOpportunityId["opportunity"] = @opportunity1
        @mapOpportunityId["opportunity"] << @opportunity2[0]
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Membership Agreement UUID'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", nil, "#{@testData['ContractEvent']['Account'][1]['UUID__c']}", membershipAgreementUUID, nil, 0, 2, "Drop").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
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
        expect(updatedOpp.fetch("Id")).to eq @opportunity2[0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Expected] Opportunity fields are successfully fetched")
        passedLogs =@objRollbar.addLog(" [Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details")
        updatedOppReservable = @contractEvent.getOppReservableDetails(updatedOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs =@objRollbar.addLog("[Result   ] Success")
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
        expect(updatedOpp.fetch("Actual_Start_Date__c")).to eq ""
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Reserved Update to Moveins Quantity?") 
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Reserved=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity']}")
        expect(updatedOpp.fetch("Total_Desks_Reserved__c").to_i).to eq 0
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "Checking Opportunity- Total Desks Move Outs..."
        expect(updatedOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity- Total Desks Reserved(net)..."
        expect(updatedOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (0 - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)

        puts "Checking Opportunity- No of Desk(s)..."
        expect(updatedOpp.fetch("Quantity__c").to_i).to eq 0

        puts "Checking Opportunity- No_of_Desks_gross__c..."
        expect(updatedOpp.fetch("No_of_Desks_gross__c").to_i).to eq 0

        puts "Checking Opportunity- Original_Contract_UUID__c..."
        expect(updatedOpp.fetch("Original_Contract_UUID__c")).to eq ""

        puts "Checking Opportunity- Stage..."
        expect(updatedOpp.fetch("StageName")).to eq "Closing"

        puts "Checking Opportunity- building..."
        expect(updatedOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- Move_Out_Building__c..."
        expect(updatedOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- No. of Desks (unweighted)..."
        expect(updatedOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq 0

        puts "Checking Opportunity- No. of Desks (weighted)..."
        expect(updatedOpp.fetch("No_of_Desks_weighted__c").to_i).to eq 0

        puts "Checking Opportunity- Contract_Type__c..."
        expect(updatedOpp.fetch("Contract_Type__c")).to eq "Downgrade"
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Reservables"

        puts "Checking OppReservable should null..."

        puts "**************************************************************************"
        puts "Checking Updated Opportunity Move Outs"

        puts "Checking Opportunity Move Outs should not null..."
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil

        puts "Checking Opportunity Move Outs- pending desk..."
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity Move Outs- Move_Out_Date__c..."
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s

        puts "**************************************************************************"

        @testRailUtility.postResult(930, "pass", 1, @run)
      rescue Exception => e
        @testRailUtility.postResult(930, e, 5, @run)
        raise e
      end
    end

    it 'C:932 In Drop event, To check if company_uuid matched with the existing opportunity and for that account there is having opportunity with the stages closed won or closed lost, while hitting payload for a particular building then new opportunity should be created.', :'932' => true do
      begin
        puts 'C:932 In Drop event, To check if company_uuid matched with the existing opportunity and for that account there is having opportunity with the stages closed won or closed lost, while hitting payload for a particular building then new opportunity should be created.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        puts "Created Opportunity"
        #@contractEvent.createOpportunity(stageName = nil, buildingNumber = nil ,contractUUID = nil)
        @opportunity1 = @contractEvent.createOpportunity(1, "Closed Won", 1, contractUUID)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        @opportunity2 = @contractEvent.createOpportunity(1, "Closed Lost", 2, nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        @mapOpportunityId["opportunity"] = @opportunity1
        @mapOpportunityId["opportunity"] << @opportunity2[0]
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Membership Agreement UUID'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", nil, "#{@testData['ContractEvent']['Account'][1]['UUID__c']}", membershipAgreementUUID, nil, 0, 2, "Drop").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
        expect(@getResponse['success']).to be true
        expect(@getResponse['result']).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected] Payload is successfully created and hitted")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        id = @getResponse['result'].split(':')[1].chomp('"').delete(' ')


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

        puts "Checking Opportunity should not null..."
        expect(createdOpp.fetch("Id")).not_to eq nil

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
        expect(createdOpp.fetch("Actual_Start_Date__c")).to eq ""
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Reserved Update to Moveins Quantity?") 
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Reserved=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity']}")
        expect(createdOpp.fetch("Total_Desks_Reserved__c").to_i).to eq 0
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "Checking Opportunity- Total Desks Move Outs..."
        expect(createdOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity- Total Desks Reserved(net)..."
        expect(createdOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (0 - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)

        puts "Checking Opportunity- No of Desk(s)..."
        expect(createdOpp.fetch("Quantity__c").to_i).to eq 0

        puts "Checking Opportunity- No_of_Desks_gross__c..."
        expect(createdOpp.fetch("No_of_Desks_gross__c").to_i).to eq 0

        puts "Checking Opportunity- Original_Contract_UUID__c..."
        expect(createdOpp.fetch("Original_Contract_UUID__c")).to eq ""

        puts "Checking Opportunity- Stage..."
        expect(createdOpp.fetch("StageName")).to eq "Closing"

        puts "Checking Opportunity- building..."
        expect(createdOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- Move_Out_Building__c..."
        expect(createdOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- Close Date..."
        d = Date.today
        expect(createdOpp.fetch("CloseDate")).to eq (d + 30).to_s

        puts "Checking Opportunity- Owner..."
        expect(createdOpp.fetch("Owner.Username")).to eq @config['Staging']['username']

        puts "Checking Opportunity- No. of Desks (unweighted)..."
        expect(createdOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq 0

        puts "Checking Opportunity- No. of Desks (weighted)..."
        expect(createdOpp.fetch("No_of_Desks_weighted__c").to_i).to eq 0

        puts "Checking Opportunity- Contract_Type__c..."
        expect(createdOpp.fetch("Contract_Type__c")).to eq "Downgrade"
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Reservables"

        puts "Checking OppReservable should null..."

        puts "**************************************************************************"
        puts "Checking Updated Opportunity Move Outs"

        puts "Checking Opportunity Move Outs should not null..."
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil

        puts "Checking Opportunity Move Outs- pending desk..."
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity Move Outs- Move_Out_Date__c..."
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s

        puts "**************************************************************************"


        @testRailUtility.postResult(932, "pass", 1, @run)
      rescue Exception => e
        @testRailUtility.postResult(932, e, 5, @run)
        raise e
      end
    end

    it 'C:935 In Drop event, To check if the company_uuid matched with the existing opportunity and for that account there is having opportunity with stages closing and contract stage as sent then new opportunity should be created.', :drop => true do
      begin
        puts 'C:935 In Drop event, To check if the company_uuid matched with the existing opportunity and for that account there is having opportunity with stages closing and contract stage as sent then new opportunity should be created.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        puts "Created Opportunity"

        @opportunity = @contractEvent.createOpportunity(1, "Closing", 1, contractUUID, "Contract Sent")
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        @mapOpportunityId["opportunity"] = @opportunity
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Membership Agreement UUID'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", nil, "#{@testData['ContractEvent']['Account'][1]['UUID__c']}", membershipAgreementUUID, nil, 0, 2, "Drop").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
        expect(@getResponse['success']).to be true
        expect(@getResponse['result']).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected] Payload is successfully created and hitted")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        id = @getResponse['result'].split(':')[1].chomp('"').delete(' ')

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

        puts "Checking Opportunity should not null..."
        expect(createdOpp.fetch("Id")).not_to eq nil

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
        expect(createdOpp.fetch("Actual_Start_Date__c")).to eq ""
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Reserved Update to Moveins Quantity?") 
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Reserved=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity']}")
        expect(createdOpp.fetch("Total_Desks_Reserved__c").to_i).to eq 0
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "Checking Opportunity- Total Desks Move Outs..."
        expect(createdOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity- Total Desks Reserved(net)..."
        expect(createdOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (0 - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)

        puts "Checking Opportunity- No of Desk(s)..."
        expect(createdOpp.fetch("Quantity__c").to_i).to eq 0

        puts "Checking Opportunity- No_of_Desks_gross__c..."
        expect(createdOpp.fetch("No_of_Desks_gross__c").to_i).to eq 0

        puts "Checking Opportunity- Original_Contract_UUID__c..."
        expect(createdOpp.fetch("Original_Contract_UUID__c")).to eq ""

        puts "Checking Opportunity- Stage..."
        expect(createdOpp.fetch("StageName")).to eq "Closing"

        puts "Checking Opportunity- building..."
        expect(createdOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- Move_Out_Building__c..."
        expect(createdOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- Close Date..."
        d = Date.today
        expect(createdOpp.fetch("CloseDate")).to eq (d + 30).to_s

        puts "Checking Opportunity- Owner..."
        expect(createdOpp.fetch("Owner.Username")).to eq @config['Staging']['username']

        puts "Checking Opportunity- No. of Desks (unweighted)..."
        expect(createdOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq 0

        puts "Checking Opportunity- No. of Desks (weighted)..."
        expect(createdOpp.fetch("No_of_Desks_weighted__c").to_i).to eq 0

        puts "Checking Opportunity- Contract_Type__c..."
        expect(createdOpp.fetch("Contract_Type__c")).to eq "Downgrade"
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Reservables"

        puts "Checking OppReservable should null..."

        puts "**************************************************************************"
        puts "Checking Updated Opportunity Move Outs"

        puts "Checking Opportunity Move Outs should not null..."
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil

        puts "Checking Opportunity Move Outs- pending desk..."
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity Move Outs- Move_Out_Date__c..."
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s

        puts "**************************************************************************"

        @testRailUtility.postResult(935, "pass", 1, @run)
      rescue Exception => e
        @testRailUtility.postResult(935, e, 5, @run)
        raise e
      end

    end

    it 'C:938 In Drop event, To check if the opportunity stage is closing but the contract stage is blank or other than contract sent or signed then new opportunity Should not be created.', :'938' => true do
      begin
        puts 'C:938 In Drop event, To check if the opportunity stage is closing but the contract stage is blank or other than contract sent or signed then new opportunity Should not be created.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        puts "Created Opportunity"

        @opportunity = @contractEvent.createOpportunity(1, "Closing", 1, contractUUID, "Contract Discarded")
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        @mapOpportunityId["opportunity"] = @opportunity
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Membership Agreement UUID'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", nil, "#{@testData['ContractEvent']['Account'][1]['UUID__c']}", membershipAgreementUUID, nil, 0, 2, "Drop").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
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
        passedLogs =@objRollbar.addLog(" [Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details")
        updatedOppReservable = @contractEvent.getOppReservableDetails(updatedOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs =@objRollbar.addLog("[Result   ] Success")
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
        expect(updatedOpp.fetch("Actual_Start_Date__c")).to eq ""
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        passedLogs = @objRollbar.addLog("[Validate] Does Total Desks Reserved Update to Moveins Quantity?") 
        passedLogs = @objRollbar.addLog("[Expected] Total Desks Reserved=#{@testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity']}")
        expect(updatedOpp.fetch("Total_Desks_Reserved__c").to_i).to eq 0
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "Checking Opportunity- Total Desks Move Outs..."
        expect(updatedOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity- Total Desks Reserved(net)..."
        expect(updatedOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (0 - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)

        puts "Checking Opportunity- No of Desk(s)..."
        expect(updatedOpp.fetch("Quantity__c").to_i).to eq 0

        puts "Checking Opportunity- No_of_Desks_gross__c..."
        expect(updatedOpp.fetch("No_of_Desks_gross__c").to_i).to eq 0

        puts "Checking Opportunity- Original_Contract_UUID__c..."
        expect(updatedOpp.fetch("Original_Contract_UUID__c")).to eq ""

        puts "Checking Opportunity- Stage..."
        expect(updatedOpp.fetch("StageName")).to eq "Closing"

        puts "Checking Opportunity- building..."
        expect(updatedOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- Move_Out_Building__c..."
        expect(updatedOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- No. of Desks (unweighted)..."
        expect(updatedOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq 0

        puts "Checking Opportunity- No. of Desks (weighted)..."
        expect(updatedOpp.fetch("No_of_Desks_weighted__c").to_i).to eq 0

        puts "Checking Opportunity- Contract_Type__c..."
        expect(updatedOpp.fetch("Contract_Type__c")).to eq "Downgrade"
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Reservables"

        puts "Checking OppReservable should null..."


        puts "**************************************************************************"
        puts "Checking Updated Opportunity Move Outs"

        puts "Checking Opportunity Move Outs should not null..."
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil

        puts "Checking Opportunity Move Outs- pending desk..."
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity Move Outs- Move_Out_Date__c..."
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s

        puts "**************************************************************************"

        @testRailUtility.postResult(938, "pass", 1, @run)
      rescue Exception => e
        @testRailUtility.postResult(938, e, 5, @run)
        raise e
      end
    end

    #********************************drop****************************************
    #********************************New Business****************************************

    it 'C:943 In New Business event, To check if the membership_agreement_uuid matched with the existing membership_agreement_uuid while hitting payload then existing opportunity should be updated.', :'943' => true do
      begin
        puts 'C:943 In New Business event, To check if the membership_agreement_uuid matched with the existing membership_agreement_uuid while hitting payload then existing opportunity should be updated.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = contractUUID
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        puts 'Created Opportunity'

        @opportunity = @contractEvent.createOpportunity(1, 'Closing', 0, contractUUID, nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        #puts (@opportunity == nil)
        @mapOpportunityId["opportunity"] = @opportunity
        #puts "Opportunity in HashMap"
        #puts @mapOpportunityId
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Membership Agreement UUID'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", nil, companyUUID, membershipAgreementUUID, nil, 0, 1, "New Business").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
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

        updatedOpp = @contractEvent.getOpportunityDetails(id)
        passedLogs = @objRollbar.addLog("[Step    ] Fetching Updated Opportunity details")
        expect(updatedOpp.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity fields are successfully fetched")
        passedLogs =@objRollbar.addLog(" [Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details")
        updatedOppReservable = @contractEvent.getOppReservableDetails(updatedOpp.fetch("Id"))
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs =@objRollbar.addLog("[Result   ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Move Outs details")
        updatedOppMoveOuts = @contractEvent.getOppMoveOutsDetails(updatedOpp.fetch("Id"))
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
        expect(updatedOpp.fetch("Total_Desks_Reserved__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "Checking Opportunity- Total Desks Move Outs..."
        expect(updatedOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq 0

        puts "Checking Opportunity- Total Desks Reserved(net)..."
        expect(updatedOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - 0)

        puts "Checking Opportunity- No of Desk(s)..."
        expect(updatedOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- No_of_Desks_gross__c..."
        expect(updatedOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- Original_Contract_UUID__c..."
        expect(updatedOpp.fetch("Original_Contract_UUID__c")).to eq membershipAgreementUUID

        puts "Checking Opportunity- Stage..."
        expect(updatedOpp.fetch("StageName")).to eq "Closing"

        puts "Checking Opportunity- building..."
        expect(updatedOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- Move_Out_Building__c..."
        expect(updatedOpp.fetch("Move_Out_Building__c")).to eq ""

        puts "Checking Opportunity- No. of Desks (unweighted)..."
        expect(updatedOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - 0)

        puts "Checking Opportunity- No. of Desks (weighted)..."
        expect(updatedOpp.fetch("No_of_Desks_weighted__c").to_i).to eq (updatedOpp.fetch("No_of_Desks_unweighted__c").to_f * (updatedOpp.fetch("Probability").to_f / 100.to_f).to_f).round

        puts "Checking Opportunity- Contract_Type__c..."
        expect(updatedOpp.fetch("Contract_Type__c")).to eq "New Business"
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Reservables"

        puts "Checking OppReservable should not null..."
        expect(updatedOppReservable.fetch("Id")).not_to eq nil

        puts "Checking OppReservable- pending desk..."
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i

        puts "Checking OppReservable- start date..."
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s

        puts "Checking OppReservable- Monthly Price..."
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Move Outs"

        puts "Checking Opportunity Move Outs should null..."


        puts "**************************************************************************"
        @testRailUtility.postResult(943, "pass", 1, @run)
      rescue Exception => e
        @testRailUtility.postResult(943, e, 5, @run)
        raise e
      end
    end

    it 'C:939 In New Business event, To check if opportunity id in the payload is matched with the opportunity_id in the system after hitting payload then existing opportunity in the system will be updated.', :'939' => true do
      begin
        puts 'C:939 In New Business event, To check if opportunity id in the payload is matched with the opportunity_id in the system after hitting payload then existing opportunity in the system will be updated.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        puts "Created Opportunity"
        @opportunity = @contractEvent.createOpportunity(1, "selling", 0, nil, nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        @mapOpportunityId["opportunity"] = @opportunity
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Membership Agreement UUID'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", @opportunity[0].fetch("Id"), companyUUID, membershipAgreementUUID, nil, 0, 1, "New Business").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
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
        expect(updatedOpp.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity fields are successfully fetched")
        passedLogs =@objRollbar.addLog(" [Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details")
        updatedOppReservable = @contractEvent.getOppReservableDetails(updatedOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs =@objRollbar.addLog("[Result   ] Success")
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
        expect(updatedOpp.fetch("Total_Desks_Reserved__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n" 

        puts "Checking Opportunity- Total Desks Move Outs..."
        expect(updatedOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq 0

        puts "Checking Opportunity- Total Desks Reserved(net)..."
        expect(updatedOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - 0)

        puts "Checking Opportunity- No of Desk(s)..."
        expect(updatedOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- No_of_Desks_gross__c..."
        expect(updatedOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- Original_Contract_UUID__c..."
        expect(updatedOpp.fetch("Original_Contract_UUID__c")).to eq ""

        puts "Checking Opportunity- Stage..."
        expect(updatedOpp.fetch("StageName")).to eq "Closing"

        puts "Checking Opportunity- building..."
        #puts  updatedOpp.fetch("Building__c")
        expect(updatedOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- Move_Out_Building__c..."
        #puts updatedOpp.fetch("Move_Out_Building__c")
        expect(updatedOpp.fetch("Move_Out_Building__c")).to eq ""

        puts "Checking Opportunity- No. of Desks (unweighted)..."
        expect(updatedOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - 0)

        puts "Checking Opportunity- No. of Desks (weighted)..."
        expect(updatedOpp.fetch("No_of_Desks_weighted__c").to_i).to eq (updatedOpp.fetch("No_of_Desks_unweighted__c").to_f * (updatedOpp.fetch("Probability").to_f / 100.to_f).to_f).round

        puts "Checking Opportunity- Contract_Type__c..."
        expect(updatedOpp.fetch("Contract_Type__c")).to eq "New Business"

        puts "**************************************************************************"
        puts "Checking Updated Opportunity Reservables"

        puts "Checking OppReservable should not null..."
        expect(updatedOppReservable.fetch("Id")).not_to eq nil

        puts "Checking OppReservable- pending desk..."
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i

        puts "Checking OppReservable- start date..."
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s

        puts "Checking OppReservable- Monthly Price..."
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Move Outs"

        puts "Checking Opportunity Move Outs should null..."


        puts "**************************************************************************"

        @testRailUtility.postResult(939, "pass", 1, @run)
      rescue Exception => e
        @testRailUtility.postResult(939, e, 5, @run)
        raise e
      end
    end

    it 'C:945 In New Business event, To check if company_uuid in the payload matched with the existing account in the system, there are having open opportunities after hitting payload if building matched with the existing open opportunity then existing opportunity should be updated.', :'945' => true do
      begin
        puts 'C:945 In New Business event, To check if company_uuid in the payload matched with the existing account in the system, there are having open opportunities after hitting payload if building matched with the existing open opportunity then existing opportunity should be updated.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        puts "Created Opportunity"
        @opportunity1 = @contractEvent.createOpportunity(1, "selling", 0, nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        @opportunity2 = @contractEvent.createOpportunity(1, "selling", 1, nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        @mapOpportunityId["opportunity"] = @opportunity1
        @mapOpportunityId["opportunity"] << @opportunity2[0]
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Membership Agreement UUID'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", nil, "#{@testData['ContractEvent']['Account'][1]['UUID__c']}", membershipAgreementUUID, nil, 0, 1, "New Business").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
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
        expect(updatedOpp.fetch("Id")).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity fields are successfully fetched")
        passedLogs =@objRollbar.addLog(" [Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details")
        updatedOppReservable = @contractEvent.getOppReservableDetails(updatedOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs =@objRollbar.addLog("[Result   ] Success")
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
        expect(updatedOpp.fetch("Total_Desks_Reserved__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- Total Desks Move Outs..."
        expect(updatedOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq 0

        puts "Checking Opportunity- Total Desks Reserved(net)..."
        expect(updatedOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i -0)

        puts "Checking Opportunity- No of Desk(s)..."
        expect(updatedOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- No_of_Desks_gross__c..."
        expect(updatedOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- Original_Contract_UUID__c..."
        expect(updatedOpp.fetch("Original_Contract_UUID__c")).to eq ""

        puts "Checking Opportunity- Stage..."
        expect(updatedOpp.fetch("StageName")).to eq "Closing"

        puts "Checking Opportunity- building..."
        expect(updatedOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- Move_Out_Building__c..."
        expect(updatedOpp.fetch("Move_Out_Building__c")).to eq ""

        puts "Checking Opportunity- No. of Desks (unweighted)..."
        expect(updatedOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - 0)

        puts "Checking Opportunity- No. of Desks (weighted)..."
        expect(updatedOpp.fetch("No_of_Desks_weighted__c").to_i).to eq (updatedOpp.fetch("No_of_Desks_unweighted__c").to_f * (updatedOpp.fetch("Probability").to_f / 100.to_f).to_f).round

        puts "Checking Opportunity- Contract_Type__c..."
        expect(updatedOpp.fetch("Contract_Type__c")).to eq "New Business"

        puts "**************************************************************************"
        puts "Checking Updated Opportunity Reservables"

        puts "Checking OppReservable should not null..."
        expect(updatedOppReservable.fetch("Id")).not_to eq nil

        puts "Checking OppReservable- pending desk..."
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i

        puts "Checking OppReservable- start date..."
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s

        puts "Checking OppReservable- Monthly Price..."
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Move Outs"

        puts "Checking Opportunity Move Outs should null..."


        puts "**************************************************************************"

        @testRailUtility.postResult(945, "pass", 1, @run)
      rescue Exception => e
        @testRailUtility.postResult(945, e, 5, @run)
        raise e
      end
    end

    it 'C:949 In New Business event, To check if company_uuid in the payload matched with the existing account in the system, there are having open opportunities after hitting payload if building does not matched with the existing open opportunity then latest opportunity will be updated.', :'949' => true do
      begin
        puts 'C:949 In New Business event, To check if company_uuid in the payload matched with the existing account in the system, there are having open opportunities after hitting payload if building does not matched with the existing open opportunity then latest opportunity will be updated.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        puts "Created Opportunity"
        #@contractEvent.createOpportunity(stageName = nil, buildingNumber = nil ,contractUUID = nil)
        @opportunity1 = @contractEvent.createOpportunity(1, "selling", 1, nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        @opportunity2 = @contractEvent.createOpportunity(1, "selling", 2, nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        @mapOpportunityId["opportunity"] = @opportunity1
        @mapOpportunityId["opportunity"] << @opportunity2[0]
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Membership Agreement UUID'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", nil, "#{@testData['ContractEvent']['Account'][1]['UUID__c']}", membershipAgreementUUID, nil, 0, 1, "New Business").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
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
        expect(updatedOpp.fetch("Id")).to eq @opportunity2[0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Expected] Opportunity fields are successfully fetched")
        passedLogs =@objRollbar.addLog(" [Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details")
        updatedOppReservable = @contractEvent.getOppReservableDetails(updatedOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs =@objRollbar.addLog("[Result   ] Success")
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
        expect(updatedOpp.fetch("Total_Desks_Reserved__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- Total Desks Move Outs..."
        expect(updatedOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq 0

        puts "Checking Opportunity- Total Desks Reserved(net)..."
        expect(updatedOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - 0)

        puts "Checking Opportunity- No of Desk(s)..."
        expect(updatedOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- No_of_Desks_gross__c..."
        expect(updatedOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- Original_Contract_UUID__c..."
        expect(updatedOpp.fetch("Original_Contract_UUID__c")).to eq ""

        puts "Checking Opportunity- Stage..."
        expect(updatedOpp.fetch("StageName")).to eq "Closing"

        puts "Checking Opportunity- building..."
        expect(updatedOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- Move_Out_Building__c..."
        expect(updatedOpp.fetch("Move_Out_Building__c")).to eq ""

        puts "Checking Opportunity- No. of Desks (unweighted)..."
        expect(updatedOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - 0)

        puts "Checking Opportunity- No. of Desks (weighted)..."
        expect(updatedOpp.fetch("No_of_Desks_weighted__c").to_i).to eq (updatedOpp.fetch("No_of_Desks_unweighted__c").to_f * (updatedOpp.fetch("Probability").to_f / 100.to_f).to_f).round

        puts "Checking Opportunity- Contract_Type__c..."
        expect(updatedOpp.fetch("Contract_Type__c")).to eq "New Business"
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Reservables"

        puts "Checking OppReservable should not null..."
        expect(updatedOppReservable.fetch("Id")).not_to eq nil

        puts "Checking OppReservable- pending desk..."
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i

        puts "Checking OppReservable- start date..."
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s

        puts "Checking OppReservable- Monthly Price..."
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Move Outs"

        puts "Checking Opportunity Move Outs should null..."


        puts "**************************************************************************"

        @testRailUtility.postResult(949, "pass", 1, @run)
      rescue Exception => e
        @testRailUtility.postResult(949, e, 5, @run)
        raise e
      end
    end

    it 'C:950 In New Business event, To check if company_uuid matched with the existing opportunity and for that account there is having opportunity with the stages closed won or closed lost, while hitting payload for a particular building then new opportunity should be created.', :'950' => true do
      begin
        puts 'C:950 In New Business event, To check if company_uuid matched with the existing opportunity and for that account there is having opportunity with the stages closed won or closed lost, while hitting payload for a particular building then new opportunity should be created.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        puts "Created Opportunity"
        #@contractEvent.createOpportunity(stageName = nil, buildingNumber = nil ,contractUUID = nil)
        @opportunity1 = @contractEvent.createOpportunity(1, "Closed Won", 1, contractUUID)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        @opportunity2 = @contractEvent.createOpportunity(1, "Closed Lost", 2, nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        @mapOpportunityId["opportunity"] = @opportunity1
        @mapOpportunityId["opportunity"] << @opportunity2[0]
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Membership Agreement UUID'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", nil, "#{@testData['ContractEvent']['Account'][1]['UUID__c']}", membershipAgreementUUID, nil, 0, 1, "New Business").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
        expect(@getResponse['success']).to be true
        expect(@getResponse['result']).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected] Payload is successfully created and hitted")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        id = @getResponse['result'].split(':')[1].chomp('"').delete(' ')
        


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

        puts "Checking Opportunity should not null..."
        expect(createdOpp.fetch("Id")).not_to eq nil

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
        expect(createdOpp.fetch("Total_Desks_Reserved__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- Total Desks Move Outs..."
        expect(createdOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq 0

        puts "Checking Opportunity- Total Desks Reserved(net)..."
        expect(createdOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - 0)

        puts "Checking Opportunity- No of Desk(s)..."
        expect(createdOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- No_of_Desks_gross__c..."
        expect(createdOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- Original_Contract_UUID__c..."
        expect(createdOpp.fetch("Original_Contract_UUID__c")).to eq ""

        puts "Checking Opportunity- Stage..."
        expect(createdOpp.fetch("StageName")).to eq "Closing"

        puts "Checking Opportunity- building..."
        expect(createdOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- Move_Out_Building__c..."
        expect(createdOpp.fetch("Move_Out_Building__c")).to eq ""

        puts "Checking Opportunity- Close Date..."
        d = Date.today
        expect(createdOpp.fetch("CloseDate")).to eq (d + 30).to_s

        puts "Checking Opportunity- Owner..."
        expect(createdOpp.fetch("Owner.Username")).to eq @config['Staging']['username']

        puts "Checking Opportunity- No. of Desks (unweighted)..."
        expect(createdOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - 0)

        puts "Checking Opportunity- No. of Desks (weighted)..."
        expect(createdOpp.fetch("No_of_Desks_weighted__c").to_i).to eq (createdOpp.fetch("No_of_Desks_unweighted__c").to_f * (createdOpp.fetch("Probability").to_f / 100.to_f).to_f).round

        puts "Checking Opportunity- Contract_Type__c..."
        expect(createdOpp.fetch("Contract_Type__c")).to eq "New Business"
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Reservables"

        puts "Checking OppReservable should not null..."
        expect(updatedOppReservable.fetch("Id")).not_to eq nil

        puts "Checking OppReservable- pending desk..."
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i

        puts "Checking OppReservable- start date..."
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s

        puts "Checking OppReservable- Monthly Price..."
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Move Outs"

        puts "Checking Opportunity Move Outs should null..."

        puts "**************************************************************************"

        @testRailUtility.postResult(950, "pass", 1, @run)
      rescue Exception => e
        @testRailUtility.postResult(950, e, 5, @run)
        raise e
      end
    end

    it 'C:951 In New Business event, To check if the company_uuid matched with the existing opportunity and for that account there is having opportunity with stages closing and contract stage as sent then new opportunity should be created.', :'951' => true do
      begin
        puts 'C:951 In New Business event, To check if the company_uuid matched with the existing opportunity and for that account there is having opportunity with stages closing and contract stage as sent then new opportunity should be created.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        puts "Created Opportunity"

        @opportunity = @contractEvent.createOpportunity(1, "Closing", 1, contractUUID, "Contract Sent")
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        @mapOpportunityId["opportunity"] = @opportunity
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Membership Agreement UUID'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", nil, "#{@testData['ContractEvent']['Account'][1]['UUID__c']}", membershipAgreementUUID, nil, 0, 1, "New Business").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
        expect(@getResponse['success']).to be true
        expect(@getResponse['result']).to_not eql nil
        passedLogs = @objRollbar.addLog("[Expected] Payload is successfully created and hitted")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        id = @getResponse['result'].split(':')[1].chomp('"').delete(' ')
        

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

        puts "Checking Opportunity should not null..."
        expect(createdOpp.fetch("Id")).not_to eq nil

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
        expect(createdOpp.fetch("Total_Desks_Reserved__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- Total Desks Move Outs..."
        expect(createdOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq 0

        puts "Checking Opportunity- Total Desks Reserved(net)..."
        expect(createdOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - 0)

        puts "Checking Opportunity- No of Desk(s)..."
        expect(createdOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- No_of_Desks_gross__c..."
        expect(createdOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- Original_Contract_UUID__c..."
        expect(createdOpp.fetch("Original_Contract_UUID__c")).to eq ""

        puts "Checking Opportunity- Stage..."
        expect(createdOpp.fetch("StageName")).to eq "Closing"

        puts "Checking Opportunity- building..."
        expect(createdOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- Move_Out_Building__c..."
        expect(createdOpp.fetch("Move_Out_Building__c")).to eq ""

        puts "Checking Opportunity- Close Date..."
        d = Date.today
        expect(createdOpp.fetch("CloseDate")).to eq (d + 30).to_s

        puts "Checking Opportunity- Owner..."
        expect(createdOpp.fetch("Owner.Username")).to eq @config['Staging']['username']

        puts "Checking Opportunity- No. of Desks (unweighted)..."
        expect(createdOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - 0)

        puts "Checking Opportunity- No. of Desks (weighted)..."
        expect(createdOpp.fetch("No_of_Desks_weighted__c").to_i).to eq (createdOpp.fetch("No_of_Desks_unweighted__c").to_f * (createdOpp.fetch("Probability").to_f / 100.to_f).to_f).round

        puts "Checking Opportunity- Contract_Type__c..."
        expect(createdOpp.fetch("Contract_Type__c")).to eq "New Business"
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Reservables"

        puts "Checking OppReservable should not null..."
        expect(updatedOppReservable.fetch("Id")).not_to eq nil

        puts "Checking OppReservable- pending desk..."
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i

        puts "Checking OppReservable- start date..."
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s

        puts "Checking OppReservable- Monthly Price..."
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Move Outs"

        puts "Checking Opportunity Move Outs should null..."
        puts "**************************************************************************"

        @testRailUtility.postResult(951, "pass", 1, @run)
      rescue Exception => e
        @testRailUtility.postResult(951, e, 5, @run)
        raise e
      end

    end

    it 'C:952 In New Business event, To check if the opportunity stage is closing but the contract stage is blank or other than contract sent or signed then new opportunity Should not be created.', :'952' => true do
      begin
        puts 'C:952 In New Business event, To check if the opportunity stage is closing but the contract stage is blank or other than contract sent or signed then new opportunity Should not be created.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        puts "Created Opportunity"

        @opportunity = @contractEvent.createOpportunity(1, "Closing", 1, contractUUID, "Contract Discarded")
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        @mapOpportunityId["opportunity"] = @opportunity
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Membership Agreement UUID'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", nil, "#{@testData['ContractEvent']['Account'][1]['UUID__c']}", membershipAgreementUUID, nil, 0, 1, "New Business").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
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
        passedLogs =@objRollbar.addLog(" [Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details")
        updatedOppReservable = @contractEvent.getOppReservableDetails(updatedOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs =@objRollbar.addLog("[Result   ] Success")
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
        expect(updatedOpp.fetch("Total_Desks_Reserved__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- Total Desks Move Outs..."
        expect(updatedOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq 0

        puts "Checking Opportunity- Total Desks Reserved(net)..."
        expect(updatedOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - 0)

        puts "Checking Opportunity- No of Desk(s)..."
        expect(updatedOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- No_of_Desks_gross__c..."
        expect(updatedOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- Original_Contract_UUID__c..."
        expect(updatedOpp.fetch("Original_Contract_UUID__c")).to eq ""

        puts "Checking Opportunity- Stage..."
        expect(updatedOpp.fetch("StageName")).to eq "Closing"

        puts "Checking Opportunity- building..."
        expect(updatedOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- Move_Out_Building__c..."
        expect(updatedOpp.fetch("Move_Out_Building__c")).to eq ""

        puts "Checking Opportunity- No. of Desks (unweighted)..."
        expect(updatedOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - 0)

        puts "Checking Opportunity- No. of Desks (weighted)..."
        expect(updatedOpp.fetch("No_of_Desks_weighted__c").to_i).to eq (updatedOpp.fetch("No_of_Desks_unweighted__c").to_f * (updatedOpp.fetch("Probability").to_f / 100.to_f).to_f).round

        puts "Checking Opportunity- Contract_Type__c..."
        expect(updatedOpp.fetch("Contract_Type__c")).to eq "New Business"
        puts "**************************************************************************"
        puts "Checking Updated Opportunity Reservables"

        puts "Checking OppReservable should not null..."
        expect(updatedOppReservable.fetch("Id")).not_to eq nil

        puts "Checking OppReservable- pending desk..."
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i

        puts "Checking OppReservable- start date..."
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s

        puts "Checking OppReservable- Monthly Price..."
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s

        puts "**************************************************************************"
        puts "Checking Updated Opportunity Move Outs"

        puts "Checking Opportunity Move Outs should null..."

        puts "**************************************************************************"

        @testRailUtility.postResult(952, "pass", 1, @run)
      rescue Exception => e
        @testRailUtility.postResult(952, e, 5, @run)
        raise e
      end
    end

    #********************************New Business****************************************
    it "Scenario 2.  To check membership agreement uuid is not passed while hitting payload then existing opportunity will not be updated." do
      @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", nil, "#{@testData['ContractEvent']['Account'][0]['UUID__c']}", nil, nil, 0, 1, "Upgrade").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
      puts "Response-->"
      puts @getResponse

      puts "Checking Responce after hitting payload..."
      expect(@getResponse['success']).to be false

      expect(@getResponse['result']).to_not eql nil

      result = @getResponse['result']
      puts result
    end

    it 'C:841 To check if the opportunity stage is updated or not when the record type is mid market.', :'841' => true do
      begin
        puts 'C:841 To check if the opportunity stage is updated or not when the record type is mid market.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        puts "Created Opportunity"
        @opportunity = @contractEvent.createOpportunity(2, "Selling", 0, nil, nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        @mapOpportunityId["opportunity"] = @opportunity
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Membership Agreement UUID'")
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

        updatedOpp = @contractEvent.getOpportunityDetails(id)
        passedLogs = @objRollbar.addLog("[Step    ] Fetching Updated Opportunity details")
        expect(updatedOpp.fetch("Id")).to eq @opportunity[0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Expected] Opportunity fields are successfully fetched")
        passedLogs =@objRollbar.addLog(" [Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details")
        updatedOppReservable = @contractEvent.getOppReservableDetails(updatedOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs =@objRollbar.addLog("[Result   ] Success")
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
        expect(updatedOpp.fetch("Total_Desks_Reserved__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- Total Desks Move Outs..."
        expect(updatedOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity- Total Desks Reserved(net)..."
        expect(updatedOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)

        puts "Checking Opportunity- No of Desk(s)..."
        expect(updatedOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- No_of_Desks_gross__c..."
        expect(updatedOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- Original_Contract_UUID__c..."
        expect(updatedOpp.fetch("Original_Contract_UUID__c")).to eq ""

        puts "Checking Opportunity- Stage..."
        expect(updatedOpp.fetch("StageName")).to eq "Closing"

        puts "Checking Opportunity- building..."
        expect(updatedOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- Move_Out_Building__c..."
        expect(updatedOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- No. of Desks (unweighted)..."
        expect(updatedOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)

        expect(updatedOpp.fetch("No_of_Desks_weighted__c").to_i).to eq (updatedOpp.fetch("No_of_Desks_unweighted__c").to_f * (updatedOpp.fetch("Probability").to_f / 100.to_f).to_f).ceil

        puts "Checking Opportunity- Contract_Type__c..."
        expect(updatedOpp.fetch("Contract_Type__c")).to eq "Upgrade"

        puts "**************************************************************************"
        puts "Checking Updated Opportunity Reservables"

        puts "Checking OppReservable should not null..."
        expect(updatedOppReservable.fetch("Id")).not_to eq nil

        puts "Checking OppReservable- pending desk..."
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i

        puts "Checking OppReservable- start date..."
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s

        puts "Checking OppReservable- Monthly Price..."
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s

        puts "**************************************************************************"
        puts "Checking Updated Opportunity Move Outs"

        puts "Checking Opportunity Move Outs should not null..."
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil

        puts "Checking Opportunity Move Outs- pending desk..."
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity Move Outs- Move_Out_Date__c..."
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s

        puts "**************************************************************************"

        @testRailUtility.postResult(841, "pass", 1, @run)
      rescue Exception => e
        @testRailUtility.postResult(841, e, 5, @run)
        raise e
      end
    end

    it 'C:843 To check if the opportunity stage is updated or not when the record type is Enterprise.', :'843' => true do
      begin
        puts 'C:843 To check if the opportunity stage is updated or not when the record type is Enterprise.'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        puts "Created Opportunity"

        @opportunity = @contractEvent.createOpportunity(3, "Selling", 0, nil, nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        @mapOpportunityId["opportunity"] = @opportunity
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Membership Agreement UUID'")
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

        updatedOpp = @contractEvent.getOpportunityDetails(id)
        passedLogs = @objRollbar.addLog("[Step    ] Fetching Updated Opportunity details")
        expect(updatedOpp.fetch("Id")).to eq @opportunity[0].fetch("Id")
        passedLogs = @objRollbar.addLog("[Expected] Opportunity fields are successfully fetched")
        passedLogs =@objRollbar.addLog(" [Result  ] Success")
        puts "\n"

        passedLogs = @objRollbar.addLog("[Step    ] Fetching Opportunity Reservable details")
        updatedOppReservable = @contractEvent.getOppReservableDetails(updatedOpp[0])
        passedLogs = @objRollbar.addLog("[Expected] Opportunity Reservable fields are successfully fetched")
        passedLogs =@objRollbar.addLog("[Result   ] Success")
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
        expect(updatedOpp.fetch("Total_Desks_Reserved__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- Total Desks Move Outs..."
        expect(updatedOpp.fetch("Total_Desks_Move_Outs__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity- Total Desks Reserved(net)..."
        expect(updatedOpp.fetch("Total_Desks_Reserved_net__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)

        puts "Checking Opportunity- No of Desk(s)..."
        expect(updatedOpp.fetch("Quantity__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- No_of_Desks_gross__c..."
        expect(updatedOpp.fetch("No_of_Desks_gross__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i

        puts "Checking Opportunity- Original_Contract_UUID__c..."
        expect(updatedOpp.fetch("Original_Contract_UUID__c")).to eq ""

        puts "Checking Opportunity- Stage..."
        expect(updatedOpp.fetch("StageName")).to eq "Closing"

        puts "Checking Opportunity- building..."
        expect(updatedOpp.fetch("Building__c")).to eq @recordCreated['building'][0].fetch("Id")

        puts "Checking Opportunity- Move_Out_Building__c..."
        expect(updatedOpp.fetch("Move_Out_Building__c")).to eq @recordCreated['building'][0].fetch("Id")


        puts "Checking Opportunity- No. of Desks (unweighted)..."
        expect(updatedOpp.fetch("No_of_Desks_unweighted__c").to_i).to eq (@testData['ContractEvent']['Scenarios'][0]['body']['products'][0]['quantity'].to_i - @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i)

        expect(updatedOpp.fetch("No_of_Desks_weighted__c").to_i).to eq (updatedOpp.fetch("No_of_Desks_unweighted__c").to_f * (updatedOpp.fetch("Probability").to_f / 100.to_f).to_f).ceil

        puts "Checking Opportunity- Contract_Type__c..."
        expect(updatedOpp.fetch("Contract_Type__c")).to eq "Upgrade"

        puts "**************************************************************************"
        puts "Checking Updated Opportunity Reservables"

        puts "Checking OppReservable should not null..."
        expect(updatedOppReservable.fetch("Id")).not_to eq nil

        puts "Checking OppReservable- pending desk..."
        expect(updatedOppReservable.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['quantity'].to_i

        puts "Checking OppReservable- start date..."
        expect(updatedOppReservable.fetch("Start_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['start_date'].to_s

        puts "Checking OppReservable- Monthly Price..."
        expect(updatedOppReservable.fetch("Monthly_Price__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_ins'][0]['price'].to_s

        puts "**************************************************************************"
        puts "Checking Updated Opportunity Move Outs"

        puts "Checking Opportunity Move Outs should not null..."
        expect(updatedOppMoveOuts.fetch("Id")).not_to eq nil

        puts "Checking Opportunity Move Outs- pending desk..."
        expect(updatedOppMoveOuts.fetch("Pending_Desks__c").to_i).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['quantity'].to_i

        puts "Checking Opportunity Move Outs- Move_Out_Date__c..."
        expect(updatedOppMoveOuts.fetch("Move_Out_Date__c")).to eq @testData['ContractEvent']['Scenarios'][0]['body']['move_outs'][0]['move_out_date'].to_s

        puts "**************************************************************************"

        @testRailUtility.postResult(843, "pass", 1, @run)
      rescue Exception => e
        @testRailUtility.postResult(843, e, 5, @run)
        raise e
      end
    end

    it 'C:865 To check if the product in the payload does not matched with the system product i.e (Different from Contract Event Utility sales console setting).', :'865' => true do
      begin
        puts 'C865 To check if the product in the payload does not matched with the system product i.e (Different from Contract Event Utility sales console setting).'
        puts "\n"
        puts "------------------------------------------------------------------------------------------------------------------"
        contractUUID = SecureRandom.uuid
        membershipAgreementUUID = SecureRandom.uuid
        companyUUID = SecureRandom.uuid
        @mapOpportunityId = Hash.new
        puts "Created Opportunity"

        @opportunity = @contractEvent.createOpportunity(3, "Selling", 0, nil)
        passedLogs = @objRollbar.addLog("[Step    ] Opportunity Should be Created With Id:#{@opportunity}, Name:#{@testData['ContractEvent']['Account'][1]['name']}, Stage:'Closing', Building:#{@testData['ContractEvent']['Building__c'][0]['Name']}, Contract UUID:#{contractUUID}", caseInfo['id'])
        expect(@opportunity).not_to eq nil
        passedLogs = @objRollbar.addLog("[Expected] Opportunity is successfully created")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"

        @mapOpportunityId["opportunity"] = @opportunity
        passedLogs = @objRollbar.addLog("[Step    ] Payload Should be Created with EventName:'Contract Sent', Search Criteria:'Based on Membership Agreement UUID'")
        @getResponse = SfRESTService.postData('' + @contractEvent.setUpPayload("Contract Sent", @opportunity[0].fetch("Id"), companyUUID, membershipAgreementUUID, "PRDE-000204", 0, 1, "Upgrade").to_json, "#{@testData['ContractEvent']['ServiceUrls'][0]['contractEvent']}", false)
        expect(@getResponse['success']).to be false
        expect(@getResponse['result']).to_not eql "Product not found. Contact to your administrator."
        passedLogs = @objRollbar.addLog("[Expected] Payload is successfully created and hitted")
        passedLogs = @objRollbar.addLog("[Result  ] Success")
        puts "\n"
        
        @testRailUtility.postResult(865, "pass", 1, @run)
      rescue Exception => e
        @testRailUtility.postResult(865, e, 5, @run)
        raise e
      end
    end

    after(:each) {
      if @mapOpportunityId != nil then
        passedLogs = @objRollbar.addLog("[Step    ] Deleting Opportunity Test Data")
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

#Created By : Monika Pingale
#Created Date : 28/12/2017
#Modified date :
require_relative "../pageObjects/manageTours(Staging).rb"
require "selenium-webdriver"
require "rspec"
require 'enziUIUtility'
require 'date'
describe ManageTours do
	before(:all){
		@driver = Selenium::WebDriver.for :chrome
		@objManageTours = ManageTours.new(@driver,"Staging")
	}
	it "C149 : to check manage tour page is displayed" , :test => true do
		@objManageTours.insertTestData(@objManageTours.instance_variable_get(:@records)[0]['lead'],"Lead")
		puts "C149 : check for lead insertion" 
		puts "\n"
		expect(ManageTours.class_variable_get(:@@recordInsertedIds)['Lead'][0]['Id']).to_not be nil
		puts "lead inserted successfully"
		puts "\n"
		puts "check for manage tour page opened"
		puts "\n"
		@objManageTours.openPage(ManageTours.class_variable_get(:@@recordInsertedIds)['Lead'][0]['Id'],:name,"lightning_manage_tours")
		#@objManageTours.openPage(@objManageTours.checkRecordCreated("Journey__c","SELECT id FROM Journey__c WHERE Primary_Email__c = '#{@objManageTours.instance_variable_get(:@records)[0]['lead'][0]['email']}'")[0].fetch('Id'),:id,"taction:0")
		expect(@driver.title).to eql "Manage Tours"
		puts "successfully opened manage tour page C149 checked"
		puts "\n"
	end
	it "C151 : to check that book tour button is disabled" do
		puts "C151 : to check that book tour button is disabled"
		puts "\n"
		expect(@objManageTours.buttonDisabled?).to be true
		puts "C151 checked"
		puts "\n"
	end
	it "C7 : to check that book tour button get enable" do
		puts "C7 : to check that book tour button get enable"
		puts "\n"
		@objManageTours.bookTour(0,false)
		sleep(8)
		expect(@objManageTours.buttonDisabled?).to be true
		puts "C7 checked"
		puts "\n"
	end
	it "C79 : to check that user can select tour date without building name", :regression => true do 
		puts "C79 : to check that user can select tour date without building name"
		puts "\n"
		sleep(3) 
		expect(@objManageTours.childDisabled?(ManageTours.selectBuilding(@driver.find_element(:id,"BookTours0"),nil),ManageTours.selectTourDate(@driver.find_element(:id,"BookTours0")))).to be false
		puts "C79 checked"
		puts "\n"
	end
	it "C80 : to check that user can select previous date as tour date" , :regression => true do 
		puts "C80 : to check that user can select previous date as tour date"
		puts "\n"
		@objManageTours.childDisabled?(ManageTours.selectBuilding(@driver.find_element(:id,"BookTours0"),"LA-Santa Monica"))
		ManageTours.selectTourDate(@driver.find_element(:id,"BookTours0"))
		expect(@objManageTours.previousDateEnabled?(Date.today.to_s)).to false
		puts "C80 checked"
		puts "\n"
	end
	it "C81 : to check that user can select start time" , :regression => true do  
		puts "C81 : to check that user can select start time"
		puts "\n"
		ManageTours.selectBuilding(@driver.find_element(:id,"BookTours0"),"LA-Santa Monica")
		ManageTours.selectTourDate(@driver.find_element(:id,"BookTours0"))
		EnziUIUtility.selectElement(@driver.find_element(:id,"BookTours0"),"Today","a")
		sleep(4)
		expect(@objManageTours.childDisabled?(ManageTours.selectTourDate(@driver.find_element(:id,"BookTours0")),ManageTours.setElementValue(@driver.find_element(:id,"BookTours0"),"startTime",nil))).to be false
		puts "C81 checked"
		puts "\n"
	end
	it "C83 : to check that user can get end time automatically after entering start time" do
		puts "C83 : to check that user can get end time automatically after entering start time"
		puts "\n"
		ManageTours.setElementValue(@driver.find_element(:id,"BookTours0"),"startTime",nil)
		sleep(10)
		expect(ManageTours.getElement("input","endTime",@driver.find_element(:id,"BookTours0"))).to_not eql nil
		puts "C83 checked"
		puts "\n"
	end
	it "C92 : to check that proper error message is displayed when user enter single character in building field" do 
		puts "C92 : to check that proper error message is displayed when user enter single character in building field"
		puts "\n"
		ManageTours.selectBuilding(@driver.find_element(:id,"BookTours0"),nil).clear
		#ManageTours.selectBuilding(@driver.find_element(:id,"BookTours0"),nil).send_keys "a"
		if ManageTours.selectBuilding(@driver.find_element(:id,"BookTours0"),nil).attribute('value').length > 2 then
			expect(@driver.find_element(:xpath ,"//span[starts-with(@id, 'lookup-option')]").text).to eql nil
			puts "C92 checked"
			puts "\n"
		else
			expect(@driver.find_element(:xpath ,"//span[starts-with(@id, 'lookup-option')]")).to_not eql nil
		end
		#ManageTours.selectBuilding(@driver.find_element(:id,"BookTours0"),nil).clear
	end
	it "C91 : to check that proper lead information is displayed on manage tour page" do
		puts "C91 : to check that proper lead information is displayed on manage tour page"
		puts "\n"
		if !@driver.find_elements(:id,"Name").empty? then
			expect(@driver.find_element(:id,"Name").attribute('value').eql? "").to be false
			expect(@driver.find_element(:id,"Name").attribute('value').eql? "#{@objManageTours.instance_variable_get(:@records)[0]['lead'][0]['firstName']}#{@objManageTours.instance_variable_get(:@records)[0]['lead'][0]['lastName']}")
    		puts "C91 checked\n"
    	end
    	if !@driver.find_elements(:id,"Company").empty? then
    		expect(@driver.find_element(:id,"Company").attribute('value').eql? "").to be false
    		expect(@driver.find_element(:id,"Company").attribute('value').eql? "#{@objManageTours.instance_variable_get(:@records)[0]['lead'][0]['company']}")
    		puts "C91 checked\n"
    	end
    	if !@driver.find_elements(:id,"Email").empty? then
    		expect(@driver.find_element(:id,"Email").attribute('value').eql? "").to be false
    		expect(@driver.find_element(:id,"Email").attribute('value').eql? "#{@objManageTours.instance_variable_get(:@records)[0]['lead'][0]['email']}")
    		puts "C91 checked\n"
    	end 
    	puts "\n"
	end
	it "C85 : to check that user can view duplicate account selector page while booking a tour" do 
		puts "C85 : to check that user can view duplicate account selector page while booking a tour"
		puts "\n"
		@objManageTours.bookTour(0,true)
		sleep(14)
		puts "header is #{@driver.find_element(:id,"header43").text}"
		puts "\n"
		expect(@driver.find_element(:id,"header43").text.eql? "Duplicate Account Selector").to be true 
		puts "C85 checked"
		puts "\n"
	end
	context "should test duplicate account selector functionality" do
		it "C86 : to check that tour is booked, when user clicks on 'create account and don't merge' button" do 
			puts "C86 : to check that tour is booked, when user clicks on 'create account and don't merge' button"
			puts "\n"
			EnziUIUtility.wait(@driver,:id,"enzi-data-table-container",100)
			@objManageTours.duplicateAccountSelector("Create Account and Don't Merge",nil)
			puts "to check lead converted"
			puts "\n" 
			expect(@objManageTours.checkRecordCreated("Lead","SELECT isConverted FROM Lead WHERE Email = '#{@objManageTours.instance_variable_get(:@records)[0]['lead'][0]['email']}'")[0].fetch("IsConverted").eql? 'true').to be true
			puts "lead converted successfully"
			puts "\n"
			puts "to check contact created"
			puts "\n"
			expect(@objManageTours.checkRecordCreated("Contact","SELECT id,total_Scheduled_Tours__c FROM Contact WHERE Email = '#{@objManageTours.instance_variable_get(:@records)[0]['lead'][0]['email']}'")[0].fetch("Id")).to_not eql nil
			puts "contact created successfully"
			puts "\n"
			puts "to check account created"
			puts "\n"
			expect(@objManageTours.checkRecordCreated("Account","SELECT id,allow_merge__c FROM Account WHERE name = '#{@objManageTours.instance_variable_get(:@records)[0]['lead'][0]['company']}'")[0].fetch("Id")).to_not eql nil
			puts "account created successfully"
			puts "\n"
			puts "to check opportunity created"
			puts "\n"
			sleep(30)
			expect(@objManageTours.checkRecordCreated("Opportunity","SELECT id FROM Opportunity WHERE Account.name = '#{@objManageTours.instance_variable_get(:@records)[0]['lead'][0]['company']}'")[0].fetch("Id")).to_not eql nil
			sleep(3)
			puts "opportunity created successfully"
			puts "\n"
			puts "to check account allow merge"
			puts "\n"
			expect(ManageTours.class_variable_get(:@@recordInsertedIds)['Account'].fetch('Allow_Merge__c').eql? 'false').to be true
			puts "allow merge status is #{ManageTours.class_variable_get(:@@recordInsertedIds)['Account'].fetch('Allow_Merge__c')}\t\n"
			puts "to check total number of scheduled tours on contact"
			puts "\n"
			sleep(10)
			expect(ManageTours.class_variable_get(:@@recordInsertedIds)['Contact'].fetch('Total_Scheduled_Tours__c').to_i > 0).to be true
			puts "total number of scheduled tours => #{ManageTours.class_variable_get(:@@recordInsertedIds)['Contact'].fetch('Total_Scheduled_Tours__c')}\t\n"
			puts "\n"
			puts "to check tour is created"
			puts "\n"
			expect(@objManageTours.checkRecordCreated("Tour_Outcome__c","SELECT id,Status__c FROM Tour_Outcome__c WHERE Primary_Member__r.email = '#{@objManageTours.instance_variable_get(:@records)[0]['lead'][0]['email']}'")[0].fetch("Id")).to_not eql nil
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
		end
		it "C89 : to check that user can view booked tours information" do
			puts "C89 : to check that user can view booked tours information"
			puts "\n"
			expect(@objManageTours.numberOfTourBooked == 3).to be true
			puts "C89 checked"
			puts "\n"
		end
		it "C94 : to check that tour is booked, when user clicks on 'create account and merge' button" do 
			puts "C94 : to check that tour is booked, when user clicks on 'create account and merge' button"
			puts "\n"
			sleep(10)
			puts "navigating to #{ManageTours.class_variable_get(:@@recordInsertedIds)['Lead'][1]['Id']}"
			puts "\n"
			@objManageTours.openPageForLead(ManageTours.class_variable_get(:@@recordInsertedIds)['Lead'][1]['Id'])
			@objManageTours.bookTour(0,true)
			sleep(5)
			@objManageTours.duplicateAccountSelector("Create Account and Merge",nil)
			puts "to check lead converted"
			puts "\n" 
			expect(@objManageTours.checkRecordCreated("Lead","SELECT isConverted FROM Lead WHERE Email = '#{@objManageTours.instance_variable_get(:@records)[0]['lead'][1]['email']}'")[0].fetch("IsConverted").eql? 'true').to be true
			puts "lead converted successfully"
			puts "\n"
			puts "to check contact created"
			puts "\n"
			expect(@objManageTours.checkRecordCreated("Contact","SELECT id,total_Scheduled_Tours__c FROM Contact WHERE Email = '#{@objManageTours.instance_variable_get(:@records)[0]['lead'][1]['email']}'")[0].fetch("Id")).to_not eql nil
			puts "contact created successfully"
			puts "\n"
			puts "to check account created"
			puts "\n"
			expect(@objManageTours.checkRecordCreated("Account","SELECT id,allow_merge__c FROM Account WHERE name = '#{@objManageTours.instance_variable_get(:@records)[0]['lead'][1]['company']}'")[0].fetch("Id")).to_not eql nil
			puts "account created successfully"
			puts "\n"
			puts "to check opportunity created"
			puts "\n"
			sleep(30)
			expect(@objManageTours.checkRecordCreated("Opportunity","SELECT id FROM Opportunity WHERE Account.name = '#{@objManageTours.instance_variable_get(:@records)[0]['lead'][1]['company']}'")[0].fetch("Id")).to_not eql nil
			puts "opportunity created successfully"
			puts "\n"
			sleep(3)
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
			expect(@objManageTours.checkRecordCreated("tour_Outcome__c","SELECT id,Status__c FROM tour_Outcome__c WHERE Primary_Member__r.email = '#{@objManageTours.instance_variable_get(:@records)[0]['lead'][1]['email']}'")[0].fetch("Id")).to_not eql nil
			puts "tour creataed successfully"
			puts "\n"
			puts "to check tour status"
			puts "\n"
			expect(ManageTours.class_variable_get(:@@recordInsertedIds)['tour_Outcome__c'].fetch('Status__c').eql? "Scheduled").to be true
			puts "status checked successfully"
			puts "\n"
			puts "to check open activities"
			expect(@objManageTours.checkRecordCreated('Task',"SELECT id FROM Task WHERE whatId = '#{ManageTours.class_variable_get(:@@recordInsertedIds)['Tour_Outcome__c'].fetch('Id')}'")[0].fetch('Id')).to_not eql nil
			puts "to check that user can view booked tours information"
			puts "\n"
			sleep(5)
			expect(@objManageTours.numberOfTourBooked == 3).to be true
			puts "C94 checked"
			puts "\n"
		end
		it "C102 : to check that tour is booked, when user clicks on 'Use Selector Account' button" , :test => true do  
			puts "C102 : to check that tour is booked, when user clicks on 'Use Selector Account' button"
			puts "\n"
			sleep(10)
			puts "navigating to #{ManageTours.class_variable_get(:@@recordInsertedIds)['Lead'][2]['Id']}"
			@objManageTours.openPageForLead(ManageTours.class_variable_get(:@@recordInsertedIds)['Lead'][2]['Id'])
			sleep(8)
			@objManageTours.bookTour(0,true)
			sleep(5)
			@objManageTours.duplicateAccountSelector("Use Selected Account","Yes")
			puts "to check lead converted"
			puts "\n" 
			expect(@objManageTours.checkRecordCreated("Lead","SELECT isConverted FROM Lead WHERE Email = '#{@objManageTours.instance_variable_get(:@records)[0]['lead'][2]['email']}'")[0].fetch("IsConverted").eql? 'true').to be true
			puts "lead converted successfully"
			puts "\n"
			puts "to check contact created"
			puts "\n"
			expect(@objManageTours.checkRecordCreated("Contact","SELECT id,Account.name FROM Contact WHERE Email = '#{@objManageTours.instance_variable_get(:@records)[0]['lead'][2]['email']}'")[0].fetch("Id")).to_not eql nil
			puts "contact created successfully"
			puts "\n"
			puts "to check tour is created"
			puts "\n"
			expect(@objManageTours.checkRecordCreated("Tour_Outcome__c","SELECT id,Status__c FROM Tour_Outcome__c WHERE Primary_Member__r.email = '#{@objManageTours.instance_variable_get(:@records)[0]['lead'][2]['email']}'")[0].fetch("Id")).to_not eql nil
			puts "tour creataed successfully"
			puts "\n"
			puts "to check tour status"
			puts "\n"
			expect(ManageTours.class_variable_get(:@@recordInsertedIds)['Tour_Outcome__c'].fetch('Status__c').eql? "Scheduled").to be true
			puts "Tour outcome id ::"+ManageTours.class_variable_get(:@@recordInsertedIds)['Tour_Outcome__c'].fetch('Id')
			puts "status checked successfully"
			puts "\n"
			sleep(30)
			#if ManageTours.class_variable_get(:@@recordInsertedIds)['Account'].fetch('Number_Of_Open_Opportunities__c').eql? 0 then
				#expect(@objManageTours.checkRecordCreated("Opportunity","SELECT id FROM Opportunity WHERE Account.email = '#{@objManageTours.instance_variable_get(:@records)[2]['existingAccount']['email']}'")[0].fetch("Id")).to_not eql nil
			#else
				#expect(@objManageTours.checkRecordCreated("Opportunity","SELECT id FROM Opportunity WHERE Account.email = '#{@objManageTours.instance_variable_get(:@records)[2]['existingAccount']['email']}'")[0]).to eql nil
			#end
			sleep(5)
			puts "to check open activities"
			expect(@objManageTours.checkRecordCreated('Task',"SELECT id FROM Task WHERE whatId = '#{ManageTours.class_variable_get(:@@recordInsertedIds)['Tour_Outcome__c'].fetch('Id')}'")[0].fetch('Id')).to_not eql nil
			puts "to check that user can view booked tours information"
			puts "\n"
			expect(@objManageTours.numberOfTourBooked == 3).to be true
			puts "C102 checked\n"
		end
	end
	context "check multiple tour booking" do
		it "C96 : to check that user can book multiple tour" do 
			puts "C96 : to check that user can book multiple tour"
			puts "\n" 
			sleep(2)
			@objManageTours.bookNewTour
			sleep(4)
			@objManageTours.bookTour(0,true)
			sleep(2)
			@objManageTours.bookTour(1,true)
			sleep(6)
			@objManageTours.duplicateAccountSelector("Create Account and Don't Merge",nil)
			sleep(30)
			puts "created tours =>  #{@objManageTours.checkRecordCreated("Tour_Outcome__c","SELECT id,Status__c FROM Tour_Outcome__c WHERE Primary_Member__r.email = '#{@objManageTours.instance_variable_get(:@records)[0]['lead'][2]['email']}'").size }\t\n"
			expect(@objManageTours.checkRecordCreated("Tour_Outcome__c","SELECT id,Status__c FROM Tour_Outcome__c WHERE Primary_Member__r.email = '#{@objManageTours.instance_variable_get(:@records)[0]['lead'][2]['email']}'").size > 1).to be true
			puts "\n"
			sleep(5)
			puts "to check open activities"
			expect(@objManageTours.checkRecordCreated('Task',"SELECT id FROM Task WHERE WhoId = '#{ManageTours.class_variable_get(:@@recordInsertedIds)['Tour_Outcome__c'].fetch('Id')}'").fetch('Id')).to_not eql nil
			puts "to check that user can view booked tours information"
			puts "\n"
			expect(@objManageTours.numberOfTourBooked == 5).to be true
			puts "C96 checked"
			puts "\n"
		end
	end
	context "should check reschedule functionality" do 
		it "C115 : to check that user can reschedule a tour" , :test => true do 
			puts "C115 : to check that user can reschedule a tour"
			puts "\n"
			sleep(3)
			puts "navigating to #{ManageTours.class_variable_get(:@@recordInsertedIds)['Lead'][3]['Id']}"
			@objManageTours.openPageForLead(ManageTours.class_variable_get(:@@recordInsertedIds)['Lead'][3]['Id'])
			@objManageTours.bookTour(0,true)
			sleep(3)
			@objManageTours.duplicateAccountSelector("Create Account and Don't Merge",nil)
			sleep(3)
			puts "to check that user can reschedule a tour"
			puts "\n"
			@objManageTours.rescheduleTour
			expect(@objManageTours.tourStatusChecked?("Reschedule")).to be true
			puts "C115 checked"
			puts "\n"
		end
		it "C129 : to check user can cancel a tour"  , :test => true do  
			puts "C129 : to check user can cancel a tour"
			puts "\n"
			EnziUIUtility.selectElement(@driver,"Cancel","button")
			EnziUIUtility.selectChild(@driver,:id,"Cancellation_Reason__c","No reason (didn't provide)","option")
			sleep(5)
			EnziUIUtility.selectElement(@driver,"Save","button") 
			puts "to check user can cancel a tour"
			puts "\n" 
			expect(@objManageTours.tourStatusChecked?("Cancelled")).to be true
			puts "C129 checked"
			puts "\n"
		end 
	end
	after(:all){
		@objManageTours.deleteTestData
		@driver.quit
	}
end
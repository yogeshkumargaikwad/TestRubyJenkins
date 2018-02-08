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
	it "T250 : to check manage tour page is displayed" , :test => true do
		puts @objManageTours.insertTestData(@objManageTours.instance_variable_get(:@records)[3]['account'],"Account")
		@objManageTours.insertTestData(@objManageTours.instance_variable_get(:@records)[3]['account'],"Account")
		@objManageTours.instance_variable_get(:@records)[2]['contact'][0]['accountId'] = ManageTours.class_variable_get(:@@recordInsertedIds)['Account']['Id']
		@objManageTours.insertTestData(@objManageTours.instance_variable_get(:@records)[2]['contact'],"Contact")
		puts "check for contact insertion" 
		puts "\n"
		expect(ManageTours.class_variable_get(:@@recordInsertedIds)['Contact']['Id']).to_not be nil
		puts "contact inserted successfully"
		puts "\n"
		puts "check for manage tour page opened"
		puts "\n"
		@objManageTours.openPage(ManageTours.class_variable_get(:@@recordInsertedIds)['Contact']['Id'],:name,"lightning_manage_tours")
		#@objManageTours.openPage(@objManageTours.checkRecordCreated("Journey__c","SELECT id FROM Journey__c WHERE Primary_Email__c = '#{@objManageTours.instance_variable_get(:@records)[0]['lead'][0]['email']}'")[0].fetch('Id'),:id,"taction:0")
		expect(@driver.title).to eql "Manage Tours"
		puts "successfully opened manage tour page T250 checked"
		puts "\n"
	end
	it "T254 : to check that book tour button get enable" do
		puts "T254 : to check that book tour button get enable"
		puts "\n"
		@objManageTours.bookTour(0,false)
		sleep(8)
		expect(@objManageTours.buttonDisabled?).to be true
		puts "T254 checked"
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
		#@objManageTours.childDisabled?(ManageTours.selectBuilding(@driver.find_element(:id,"BookTours0"),"LA-Santa Monica"))
		ManageTours.selectTourDate(@driver.find_element(:id,"BookTours0"))
		expect(@objManageTours.previousDateEnabled?(Date.today.to_s)).to false
		puts "C80 checked"
		puts "\n"
	end
	it "T251 : to check that user can select start time" , :regression => true do  
		puts "T251 : to check that user can select start time"
		puts "\n"
		ManageTours.selectBuilding(@driver.find_element(:id,"BookTours0"),"LA-Santa Monica")
		ManageTours.selectTourDate(@driver.find_element(:id,"BookTours0"))
		EnziUIUtility.selectElement(@driver.find_element(:id,"BookTours0"),"Today","a")
		sleep(4)
		expect(@objManageTours.childDisabled?(ManageTours.selectTourDate(@driver.find_element(:id,"BookTours0")),ManageTours.setElementValue(@driver.find_element(:id,"BookTours0"),"startTime",nil))).to be false
		puts "T251 checked"
		puts "\n"
	end
	it "T252 : to check that user can get end time automatically after entering start time" do
		puts "T252 : to check that user can get end time automatically after entering start time"
		puts "\n"
		ManageTours.setElementValue(@driver.find_element(:id,"BookTours0"),"startTime",nil)
		sleep(10)
		expect(ManageTours.getElement("input","endTime",@driver.find_element(:id,"BookTours0"))).to_not eql nil
		puts "T252 checked"
		puts "\n"
	end
	it "T253 : to check that proper error message is displayed when user enter single character in building field" do 
		puts "T253 : to check that proper error message is displayed when user enter single character in building field"
		puts "\n"
		ManageTours.selectBuilding(@driver.find_element(:id,"BookTours0"),nil).clear
		#ManageTours.selectBuilding(@driver.find_element(:id,"BookTours0"),nil).send_keys "a"
		if ManageTours.selectBuilding(@driver.find_element(:id,"BookTours0"),nil).attribute('value').length > 2 then
			expect(@driver.find_element(:xpath ,"//span[starts-with(@id, 'lookup-option')]").text).to eql nil
			puts "T253 checked"
			puts "\n"
		else
			expect(@driver.find_element(:xpath ,"//span[starts-with(@id, 'lookup-option')]")).to_not eql nil
		end
		#ManageTours.selectBuilding(@driver.find_element(:id,"BookTours0"),nil).clear
	end
	it "T249 : to check that proper contact information is displayed on manage tour page" do
		puts "T249 : to check that proper lead information is displayed on manage tour page"
		puts "\n"
		if !@driver.find_elements(:id,"Contact").empty? then
			expect(@driver.find_element(:id,"Contact").attribute('value').eql? "").to be false
			expect(@driver.find_element(:id,"Contact").attribute('value').eql? "#{@objManageTours.instance_variable_get(:@records)[2]['contact']['firstName']}#{@objManageTours.instance_variable_get(:@records)[2]['contact']['lastName']}")
    		puts "T249 checked\n"
    	end
    	if !@driver.find_elements(:id,"FTE").empty? then
    		expect(@driver.find_element(:id,"FTE").attribute('value').eql? "").to be false
    		expect(@driver.find_element(:id,"FTE").attribute('value').eql? "#{@objManageTours.instance_variable_get(:@records)[2]['contact']['companySize']}")
    		puts "T249 checked\n"
    	end
    	if !@driver.find_elements(:id,"InterestedDesks").empty? then
    		expect(@driver.find_element(:id,"InterestedDesks").attribute('value').eql? "").to be false
    		expect(@driver.find_element(:id,"InterestedDesks").attribute('value').eql? "#{@objManageTours.instance_variable_get(:@records)[2]['contact']['numberOfDesks']}")
    		puts "T249 checked\n"
    	end
    	if !@driver.find_elements(:id,"Opportunity").empty? then
    		expect(@driver.find_element(:id,"Opportunity").attribute('value').eql? "").to be false
    		expect(@driver.find_element(:id,"Opportunity").attribute('value').eql? "#{@objManageTours.instance_variable_get(:@records)[2]['contact']['opportunity']}")
    		puts "T249 checked\n"
    	end  
    	puts "\n"
	end
	it "T362 :to check that user can book a tour" do 
		puts "T362 :to check that user can book a tour"
		@objManageTours.bookTour(0,true)
		puts "\n"
		puts "to check opportunity created"
		puts "\n"
		sleep(30)
		expect(@objManageTours.checkRecordCreated("Opportunity","SELECT id FROM Opportunity WHERE Account.name = '#{@objManageTours.instance_variable_get(:@records)[0]['lead'][0]['company']}'")[0].fetch("Id")).to_not eql nil
		sleep(3)
		puts "opportunity created successfully"
		puts "\n"
		sleep(10)
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
		puts "T362 checked"
		puts "\n"
	end
	it "T260: to check that user can view booked tours information" do
		puts "T260: to check that user can view booked tours information"
		puts "\n"
		expect(@objManageTours.numberOfTourBooked == 3).to be true
		puts "T260 checked"
		puts "\n"
	end
	context "check multiple tour booking" do
		it "T261 : to check that user can book multiple tour" do 
			puts "T261 : to check that user can book multiple tour"
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
			puts "T261 checked"
			puts "\n"
		end
	end
	context "should check tour reschedule and cancel functionality" do 
		it "T262 : to check that user can reschedule a tour" , :test => true do 
			puts "T262 : to check that user can reschedule a tour"
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
			expect(@objManageTours.tourRescheduled?).to be true
			puts "T262 checked"
			puts "\n"
		end
		it "T263 : to check user can cancel a tour"  , :test => true do  
			puts "T263 : to check user can cancel a tour"
			puts "\n"
			EnziUIUtility.selectElement(@driver,"Cancel","button")
			EnziUIUtility.selectChild(@driver,:id,"Cancellation_Reason__c","No reason (didn't provide)","option")
			sleep(5)
			EnziUIUtility.selectElement(@driver,"Save","button") 
			puts "to check user can cancel a tour"
			puts "\n" 
			expect(@objManageTours.checkRecordCreated("Tour_Outcome__c","SELECT id,Status__c FROM Tour_Outcome__c WHERE Primary_Member__r.email = '#{@objManageTours.instance_variable_get(:@records)[0]['lead'][3]['email']}'")[0].fetch('Status__c').eql? "Cancelled").to be true
			puts "T263 checked"
			puts "\n"
		end 
	end
	after(:all){
		@objManageTours.deleteTestData
		@driver.quit
	}
end
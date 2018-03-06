#Created By : Pragalbha Mahajan
#Created Date : 28/12/2017
#Modified date :

require "selenium-webdriver"
require 'enziUIUtility'
require "rspec"
#require "metaforce"
#require_relative 'E:\Projects\Training\Contact Availability\pageObject\ReservableAvailability.rb'
require_relative File.expand_path(Dir.pwd + '/Reservable Availability/pageObject/ReservableAvailability.rb')

describe "Reservable Availability Tester" do
  before(:all) {
    @driver = Selenium::WebDriver.for :chrome
    @objReservableAvailability = ReservableAvailability.new(@driver)
    testRecordFile = File.open(Dir.pwd + "/Reservable Availability/TestData/Test_ContactRecord.json", "r")
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
      @run = @testRailUtility.addRun("Reservable Availability Run",4,22,arrCaseIds)['id']
    else
      @run = ENV['RUN_ID']
    end
    if ENV['RUN_ID'].nil? then
      @runId = @testRailUtility.addRun("Reservable Availability Run",4,22,arrCaseIds)['id']
    end
=end

	@run = ENV['RUN_ID']
  }

  context "Navigation to Reservable Availability Page" do
    before(:example){
      puts ""
      puts "-----------------------------------------------------------------------------------------------"
    }
    it "should go to Home page", :sanity => true do
      if expect(@objReservableAvailability.getDriver.title).to eq "Salesforce - Unlimited Edition"
        puts "Successfully redirected to Home Page"
      end
    end

    it "should go to Reservable Availability Page", :sanity => true do
      @objReservableAvailability.redirectToAvailability()
      puts "Successfully redirected to Reservable Availability Page"
      sleep(10)
    end
  end

=begin
  context "context tagname demo" do
    it "demo it" do
      @objReservableAvailability.selectElement("No", :option)
    end
  end
=end

=begin
	it "should create a Account" do
		if expect(@objReservableAvailability.createAccount()).not_to be_nil
			puts "Account Successfully Created"
		end
	end

	it "should create a Contact" do
		if expect(@objReservableAvailability.createContact()).not_to be_nil
			puts "Contact Successfully Created"
		end
	end

	it "should go to Contact Details Page" do
		@objReservableAvailability.redirectToContactDetail()
		if expect(@objReservableAvailability.getDriver.title).to eq "Contact: Sharma ~ Salesforce - Unlimited Edition"
			puts "Successfully Redirected to Contact Detail Page"
		end
	end

	it "should go to Availability Page of Contact" do
		@objReservableAvailability.redirectToAvailability()
		#puts "Inside Spec: #{@objReservableAvailability.getDriver.title}"
		#expect(@objReservableAvailability.getDriver.title).to eq "Availability"
	end

=end

  context "Validate Preset View, Submit and Save Buttons" do
    before(:example){
      puts ""
      puts "-----------------------------------------------------------------------------------------------"
    }
    #before(:example){
    #sleep(10)
    #@objReservableAvailability.resetForm("Select Preset Views", "Select City", "Minimum_Capacity__c", "Maximum_Capacity__c", "Minimum_Price_Range__c", "Maximum_Price_Range__c")
    #}

=begin
		it "C95:To check when nothing is selected, Save as preset view, Save & Submit button should be disabled.", :regression => true do
			expect(@objReservableAvailability.buttonEnabled?("btnSaveAsPresetView")).to eq false
			expect(@objReservableAvailability.buttonEnabled?("btnSave")).to eq false	
			expect(@objReservableAvailability.buttonEnabled?("btnSubmit")).to eq false
		end
=end

=begin
		it "C46:To check when after selecting particular city, Save as preset view and Submit button should not visible.", :regression => true do
			@objReservableAvailability.resetForm("Select Preset Views", "Select City", "Minimum_Capacity__c", "Maximum_Capacity__c", "Minimum_Price_Range__c", "Maximum_Price_Range__c")
			@objReservableAvailability.setCity(@testRecords['scenario:2']['SetCity'])	
			expect(@objReservableAvailability.buttonEnabled?("btnSaveAsPresetView")).to eq false
			expect(@objReservableAvailability.buttonEnabled?("btnSave")).to eq false	
			expect(@objReservableAvailability.buttonEnabled?("btnSubmit")).to eq false
		end
=end

=begin
		it "C45:To check when after selecting date from available from, Save as preset view and Submit button should not visible.", :regression => true do
			@objReservableAvailability.resetForm("Select Preset Views", "Select City", "Minimum_Capacity__c", "Maximum_Capacity__c", "Minimum_Price_Range__c", "Maximum_Price_Range__c")
			@objReservableAvailability.setAvailableFrom(@testRecords['scenario:3']['SetAvailableForm'][0])	#2019-02-23
			expect(@objReservableAvailability.buttonEnabled?("btnSaveAsPresetView")).to eq false
			expect(@objReservableAvailability.buttonEnabled?("btnSave")).to eq false	
			expect(@objReservableAvailability.buttonEnabled?("btnSubmit")).to eq false
		end
=end

    #Use: This it passes the Preset View name to setPresetView function
    it "C56:To check when after selecting any preset view, save as preset view, Save & Submit button  will be enabled", :sanity => true do
      begin
      @objReservableAvailability.setPresetView(@testRecords['scenario:4']['SetPresetView'][0]) #Available 1ps in NYC
      expect(@objReservableAvailability.buttonEnabled?("btnSaveAsPresetView")).to eq true
      expect(@objReservableAvailability.buttonEnabled?("btnSave")).to eq true
      expect(@objReservableAvailability.buttonEnabled?("btnSubmit")).to eq true
      puts "Save as preset view, Save & Submit buttons are successfully Enabled"

      @testRailUtility.postResult(56,"comment",1,@run)
      rescue Exception => e
        @testRailUtility.postResult(56,e,5,@run)
        puts e
        raise e
      end
    end

    #Use: This it passes the City name to setCity function and Date to setAvailableFrom function
    it "C113:To check when after selecting date and particular city, Save as preset view and Submit button should be visible.", :sanity => true do
      begin
      @objReservableAvailability.resetForm("Select Preset Views", "Select City", "Minimum_Capacity__c", "Maximum_Capacity__c", "Minimum_Price_Range__c", "Maximum_Price_Range__c")
      @objReservableAvailability.setCity(@testRecords['scenario:2']['SetCity']) #Paris
      @objReservableAvailability.setAvailableFrom(@testRecords['scenario:3']['SetAvailableForm'][0]) #2019-02-23
      expect(@objReservableAvailability.buttonEnabled?("btnSaveAsPresetView")).to eq true
      expect(@objReservableAvailability.buttonEnabled?("btnSave")).to eq false
      expect(@objReservableAvailability.buttonEnabled?("btnSubmit")).to eq true
      puts "Save as preset view & Submit buttons are successfully Enabled and Save button is successfully disabled"

      @testRailUtility.postResult(113,"comment",1,@run)
      rescue Exception => e
        @testRailUtility.postResult(113,e,5,@run)
        puts e
        raise e
      end
    end
  end

  context 'Testing related to Creating Preset View' do
    before(:example){
      puts ""
      puts "-----------------------------------------------------------------------------------------------"
    }

=begin
    it 'should Open and close Create Preset View Dialog', :regression => true do
      @objReservableAvailability.closePresetViewDialog()
    end

    it 'should not create the view with blankName', :regression => true do
      expect(@objReservableAvailability.createPresetView('')).to eq nil
      @objReservableAvailability.closeSetPresetViewModal()
    end
=end

    it 'C170:To check after saving as preset view it should be displayed in preset view list', :sanity => false do
      begin
      EnziUIUtility.wait(@driver, :id, "Minimum_Capacity__c", 30)
      #EnziUIUtility.wait(@driver,nil,nil,20)
      @objReservableAvailability.resetForm("Select Preset Views", "Select City", "Minimum_Capacity__c", "Maximum_Capacity__c", "Minimum_Price_Range__c", "Maximum_Price_Range__c")
      @objReservableAvailability.setAvailableFrom('2018-11-22')
      @objReservableAvailability.setCity('Austin')
      @objReservableAvailability.setUnitType(["Bed", "HotDesk", "DedicatedDesk"])
      @objReservableAvailability.showRecords('Available')
      @objReservableAvailability.selectbuildings(@testRecords['scenario:9']["buildings"])
      expect(@objReservableAvailability.createPresetView(@testRecords['scenario:10']['CreatePresetView'][2])).to eq @testRecords['scenario:10']['CreatePresetView'][2]
      puts "Preset view is successfully created"

      @testRailUtility.postResult(170,"comment",1,@run)
      rescue Exception => e
        @testRailUtility.postResult(170,e,5,@run)
        puts e
        raise e
      end
    end
  end


  context "Testing Available form Elements" do
    before(:example){
      puts ""
      puts "-----------------------------------------------------------------------------------------------"
    }
=begin
		it 'C31:To check when While selecting "available from" in reservable availability page, previous date should not be selected.', :regression => true do
			expect(@objReservableAvailability.setAvailableFrom(@testRecords['scenario:3']['SetAvailableForm'][1])).to eq false	#2017-01-25
		end
=end

    it 'C105:To check when after clicking on "today" in "available from", todays date should be selected.', :sanity => true do
      begin
      expect(@objReservableAvailability.clickToday()).to eq true
      puts "Todays date is successfully selected"

      @testRailUtility.postResult(105,"comment",1,@run)
      rescue Exception => e
        @testRailUtility.postResult(105,e,5,@run)
        puts e
        raise e
      end
    end

    it 'C106:To check when after clicking on "clear" in "available from", selected date should be removed.', :sanity => true do
      begin
      expect(@objReservableAvailability.clickClear()).to eq true
      puts "Selected Date is successfully cleared"

      @testRailUtility.postResult(106,"comment",1,@run)
      rescue Exception => e
        @testRailUtility.postResult(106,e,5,@run)
        puts e
        raise e
      end
    end

=begin
		it 'C36:To check when after clicking on "Close" in "available from", date calendar should be closed.', :regression => true do
			expect(@objReservableAvailability.clickClose()).to eq true
		end
=end
  end

  context "Testing Min Max Capacity Elements" do
    before(:example) {
      puts ""
      puts "-----------------------------------------------------------------------------------------------"
      @objReservableAvailability.resetForm(nil, nil, "Minimum_Capacity__c", "Maximum_Capacity__c", "Minimum_Price_Range__c", "Maximum_Price_Range__c")
    }
    it 'C107:To check when after entering minimum capacity less than maximum capacity, error message should not be displayed.', :sanity => true do
      begin
      @objReservableAvailability.setTextBoxValue("Minimum_Capacity__c", @testRecords['scenario:5']['SetMinCapacity'][0]) #10
      @objReservableAvailability.setTextBoxValue("Maximum_Capacity__c", @testRecords['scenario:6']['SetMaxCapacity'][1]) #20
      expect(@objReservableAvailability.checkError("Minimum_Capacity__c")).to eq false
      expect(@objReservableAvailability.checkError("Maximum_Capacity__c")).to eq false
      puts "Error message is not displayed because of valid input"

      @testRailUtility.postResult(107,"comment",1,@run)
      rescue Exception => e
        @testRailUtility.postResult(107,e,5,@run)
        puts e
        raise e
      end
    end

=begin
		it 'C38:To check when after entering minimum capacity more then maximum capacity, "Invalid Value" as error message will be displayed.', :regression => true do
			@objReservableAvailability.setTextBoxValue("Minimum_Capacity__c",@testRecords['scenario:5']['SetMinCapacity'][0])	#10
			@objReservableAvailability.setTextBoxValue("Maximum_Capacity__c",@testRecords['scenario:6']['SetMaxCapacity'][2])	#5
			expect(@objReservableAvailability.checkError("Minimum_Capacity__c")).to eq false
			expect(@objReservableAvailability.checkError("Maximum_Capacity__c")).to eq true
		end
=end

    it 'C108:To check when after entering minimum capacity less than or equal to maximum capacity, error message should not be displayed.', :sanity => true do
      begin
      @objReservableAvailability.setTextBoxValue("Minimum_Capacity__c", @testRecords['scenario:5']['SetMinCapacity'][0]) #10
      @objReservableAvailability.setTextBoxValue("Maximum_Capacity__c", @testRecords['scenario:6']['SetMaxCapacity'][0]) #10
      expect(@objReservableAvailability.checkError("Minimum_Capacity__c")).to eq false
      expect(@objReservableAvailability.checkError("Maximum_Capacity__c")).to eq false
      puts "Error message is not displayed because of valid input"

      @testRailUtility.postResult(108,"comment",1,@run)
      rescue Exception => e
        @testRailUtility.postResult(108,e,5,@run)
        puts e
        raise e
      end
    end

    it 'C40:To check when after entering minimum capacity more then maximum capacity and again minimum capacity changed less than maximum capacity, error message should not be displayed.', :sanity => true do
      begin
      @objReservableAvailability.setTextBoxValue("Minimum_Capacity__c", @testRecords['scenario:5']['SetMinCapacity'][0]) #10
      @objReservableAvailability.setTextBoxValue("Maximum_Capacity__c", @testRecords['scenario:6']['SetMaxCapacity'][2]) #5
      @objReservableAvailability.setTextBoxValue("Minimum_Capacity__c", @testRecords['scenario:5']['SetMinCapacity'][7]) #4
      expect(@objReservableAvailability.checkError("Minimum_Capacity__c")).to eq false
      expect(@objReservableAvailability.checkError("Maximum_Capacity__c")).to eq false
      puts "Error message is not displayed because of valid input"
      #@objReservableAvailability.checkError()

      @testRailUtility.postResult(40,"comment",1,@run)
      rescue Exception => e
        @testRailUtility.postResult(40,e,5,@run)
        puts e
        raise e
      end
    end
  end

  context "Testing Min Max Price Range Elements" do
    before(:example) {
      puts ""
      puts "-----------------------------------------------------------------------------------------------"
      @objReservableAvailability.resetForm(nil, nil, "Minimum_Capacity__c", "Maximum_Capacity__c", "Minimum_Price_Range__c", "Maximum_Price_Range__c")
    }
    it 'C110:To check when after entering minimum price range less than maximum price range, error message should not be displayed.', :sanity => true do
      begin
      @objReservableAvailability.setTextBoxValue("Minimum_Price_Range__c", @testRecords['scenario:7']['setMinPriceRange'][0]) #1000
      @objReservableAvailability.setTextBoxValue("Maximum_Price_Range__c", @testRecords['scenario:8']['setMaxPriceRange'][1]) #2000
      expect(@objReservableAvailability.checkError("Minimum_Price_Range__c")).to eq false
      expect(@objReservableAvailability.checkError("Maximum_Price_Range__c")).to eq false
      puts "Error message is not displayed because of valid input"

      @testRailUtility.postResult(110,"comment",1,@run)
      rescue Exception => e
        @testRailUtility.postResult(110,e,5,@run)
        puts e
        raise e
      end
    end

=begin
		it 'C42:To check when after entering minimum price range more then maximum price range, "Invalid value" as error message should be displayed.', :sanity => true do
			@objReservableAvailability.setTextBoxValue("Minimum_Price_Range__c",@testRecords['scenario:7']['setMinPriceRange'][1])	#2000
			@objReservableAvailability.setTextBoxValue("Maximum_Price_Range__c",@testRecords['scenario:8']['setMaxPriceRange'][2])	#1500
			expect(@objReservableAvailability.checkError("Minimum_Price_Range__c")).to eq false
			expect(@objReservableAvailability.checkError("Maximum_Price_Range__c")).to eq true
		end
=end

    it 'C111:To check when after entering minimum price range less than or equal to maximum price range, error message should not be displayed.', :sanity => true do
      begin
      @objReservableAvailability.setTextBoxValue("Minimum_Price_Range__c", @testRecords['scenario:7']['setMinPriceRange'][1]) #2000
      @objReservableAvailability.setTextBoxValue("Maximum_Price_Range__c", @testRecords['scenario:8']['setMaxPriceRange'][2]) #2000
      expect(@objReservableAvailability.checkError("Minimum_Price_Range__c")).to eq false
      expect(@objReservableAvailability.checkError("Maximum_Price_Range__c")).to eq false
      puts "Error message is not displayed because of valid input"

      @testRailUtility.postResult(111,"comment",1,@run)
      rescue Exception => e
        @testRailUtility.postResult(111,e,5,@run)
        puts e
        raise e
      end
    end

    it 'C112:To check when after entering minimum price range more than maximum price range and again minimum price range changed less than maximum price range, error message should not be displayed.', :sanity => true do
      begin
      @objReservableAvailability.setTextBoxValue("Minimum_Price_Range__c", @testRecords['scenario:7']['setMinPriceRange'][1]) #2000
      @objReservableAvailability.setTextBoxValue("Maximum_Price_Range__c", @testRecords['scenario:8']['setMaxPriceRange'][2]) #1500
      @objReservableAvailability.setTextBoxValue("Minimum_Price_Range__c", @testRecords['scenario:7']['setMinPriceRange'][0]) #1000
      expect(@objReservableAvailability.checkError("Minimum_Price_Range__c")).to eq false
      expect(@objReservableAvailability.checkError("Maximum_Price_Range__c")).to eq false
      puts "Error message is not displayed because of valid input"

      @testRailUtility.postResult(112,"comment",1,@run)
      rescue Exception => e
        @testRailUtility.postResult(112,e,5,@run)
        puts e
        raise e
      end
    end

=begin
    it 'C:To check when after entering minimum price range less than maximum price range and again minimum price range changed greater than maximum price range, error message should be displayed.', :regression => true do
      @objReservableAvailability.setTextBoxValue("Minimum_Price_Range__c", 10) #2000
      @objReservableAvailability.setTextBoxValue("Maximum_Price_Range__c", 20) #1500
      @objReservableAvailability.setTextBoxValue("Minimum_Price_Range__c", 21) #1000
      expect(@objReservableAvailability.checkError("Minimum_Price_Range__c")).to eq true
      expect(@objReservableAvailability.checkError("Maximum_Price_Range__c")).to eq false
    end
=end
  end

  context "Testing Unit Type Elements" do
    before(:example){
      puts ""
      puts "-----------------------------------------------------------------------------------------------"
    }
=begin
		it "Should show correct Unit types on availability page" do
			@objReservableAvailability.checkUnitType()
		end
		#Use: This it passes searchText to searchUnitType method
		it 'Should search Unit type on availability page' do
			@objReservableAvailability.searchUnitType("b")
		end
=end
    it 'C117:To check while searching unit type other than the predefined unit type, "No records found!" message should be displayed.' do
      begin
      expect(@objReservableAvailability.unitTypeError("z")).to eq true
      puts "No records found! message successfully displayed."

      @testRailUtility.postResult(117,"comment",1,@run)
      rescue Exception => e
        @testRailUtility.postResult(117,e,5,@run)
        puts e
        raise e
      end
    end
  end

  context "Testing Building Elements" do
    before(:example){
      puts ""
      puts "-----------------------------------------------------------------------------------------------"
    }

    it 'C116:To check while searching building without selecting city, "No records found!" message should be displayed.', :sanity => true do
      begin
      expect(@objReservableAvailability.isErrorInBuilding()).to eq true #Select City
      puts "No records found! message successfully displayed."

      @testRailUtility.postResult(116,"comment",1,@run)
      rescue Exception => e
        @testRailUtility.postResult(116,e,5,@run)
        puts e
        raise e
      end
    end

    #Use: This it passes the City Name to checkBuilding function
    it 'C114:To check Building is displayed as per the selected city', :sanity => true do
      begin
      expect(@objReservableAvailability.checkBuilding("Beijing")).to eq true
      puts "Buildings are successfully displayed as per selected city"

      @testRailUtility.postResult(114,"comment",1,@run)
      rescue Exception => e
        @testRailUtility.postResult(114,e,5,@run)
        puts e
        raise e
      end
    end

=begin
    it 'To check while searching Building type proper results should be shown according to Building type', :regression => true do
      expect(@objReservableAvailability.checkPattern("Paris", "f")).to eq true
    end
=end
  end

  context "Testing setPresetview Elements" do
    before(:example){
      puts ""
      puts "-----------------------------------------------------------------------------------------------"
    }

    #Use: This it passes the Preset View name to setPresetView function
    it 'should set preset view on availability page', :sanity => true do
      expect(@objReservableAvailability.setPresetView(@testRecords['scenario:4']['SetPresetView'][1])).to eq true
      puts "Preset view is successfully set"
    end

    #Use: This it passes the buttonId to clickButton function
    it 'C103:To check user able to see the availability of building reservables.', :sanity => true do
      begin
      @objReservableAvailability.clickButton("btnSubmit")
      #sleep(15)
      #EnziUIUtility.clickElement(@driver,:id,"btnNext")

      @testRailUtility.postResult(103,"comment",1,@run)
      rescue Exception => e
        @testRailUtility.postResult(103,e,5,@run)
        puts e
        raise e
      end
    end
  end

  context 'Testing related to Reservable Table' do
    before(:example){
      puts ""
      puts "-----------------------------------------------------------------------------------------------"
    }
=begin
		it 'should select reservable by clicking checkbox', :sanity => true do      		#In Development
			arrBuildingUnit = @objReservableAvailability.getBuildingUnits
			if arrBuildingUnit.count > 0
			    @objReservableAvailability.selectReservables(arrBuildingUnit[0])
			    @objReservableAvailability.selectReservables(arrBuildingUnit[1])
			else
			   	puts 'No records to display'
			end
		end

		it 'should click on send proposal button', :sanity => true do
			expect(@objReservableAvailability.clickElement("sendProposal")).to eq true	
		end

		it 'C104:To check user able to get the proposal form for a particular building in reservable availability page.', :sanity => true do
		    unitsFlag = @objReservableAvailability.getDriver
		    @objReservableAvailability.checkSendProposalTableUnits()
		    expect(nil).not_to  eq(unitsFlag)
  		end

  		it 'Should get table headers', :sanity => true  do
  			#@objReservableAvailability.getHeaders()
  		end

      it 'Should get tables all data', :sanity => true do
      #@objReservableAvailability.getAllData(false)
    end
=end

=begin
  		it 'C118:To check when after selecting show records as "Available", only unoccupied buildings will be displayed.', :sanity => true do
  			expect(@objReservableAvailability.checkShowRecord()).to eq true
  		end

  		it 'C53:To check when after selecting show records as "All", all occupied and unoccupied buildings will be displayed.', :sanity => true do
  			@objReservableAvailability.setAvailableFrom('2018-11-22')
			@objReservableAvailability.setCity('Austin')
			@objReservableAvailability.showRecords('All')
			@objReservableAvailability.clickButton("btnSubmit")
  			expect(@objReservableAvailability.checkShowRecord()).to eq false
  		end
=end

    it 'C118:To check when after selecting show records as "Available", only unoccupied buildings will be displayed.', :sanity => true do
      begin
      expect(@objReservableAvailability.checkShowRecord()).to eq true
      puts "Successfully showing unoccupied buildings"

      @testRailUtility.postResult(118,"comment",1,@run)
      rescue Exception => e
        @testRailUtility.postResult(118,e,5,@run)
        puts e
        raise e
      end
    end

    it 'C53:To check when after selecting show records as "All", all occupied and unoccupied buildings will be displayed.', :sanity => true do
      begin
      @objReservableAvailability.setAvailableFrom('2018-11-22')
      @objReservableAvailability.setCity('Austin')
      @objReservableAvailability.showRecords('All')
      @objReservableAvailability.clickButton("btnSubmit")
      expect(@objReservableAvailability.checkShowRecord()).to eq false
      puts "Successfully showing Occupied and Unoccupied buildings"

      @testRailUtility.postResult(53,"comment",1,@run)
      rescue Exception => e
        @testRailUtility.postResult(53,e,5,@run)
        puts e
        raise e
      end
    end

=begin
    it 'To check when after selecting include pending contract as "Yes", pending contract and non pending contract available reservables will be displayed', :sanity => true do
      @objReservableAvailability.setAvailableFrom('2018-11-22')
      @objReservableAvailability.setCity('Austin')
      @objReservableAvailability.showRecords('All')
      @objReservableAvailability.selectElement("Yes", :option)
      @objReservableAvailability.checkPendingContracts()
    end
=end

    it 'should select reservable by clicking checkbox', :sanity => true do      		#In Development
      arrBuildingUnit = @objReservableAvailability.getBuildingUnits
      if arrBuildingUnit.count > 0
        @objReservableAvailability.selectReservables(arrBuildingUnit[0])
        @objReservableAvailability.selectReservables(arrBuildingUnit[1])
        puts "Successfully selected reservables by clicking on checkbox"
      else
        puts 'No records to display'
      end
    end

    it 'should click on send proposal button', :sanity => true do
      expect(@objReservableAvailability.clickElement("sendProposal")).to eq true
    end

    it 'C104:To check user able to get the proposal form for a particular building in reservable availability page.', :sanity => true do
      begin
      unitsFlag = @objReservableAvailability.getDriver
      @objReservableAvailability.checkSendProposalTableUnits()
      expect(nil).not_to  eq(unitsFlag)
      puts "Successfully showing proposal form"

      @testRailUtility.postResult(104,"comment",1,@run)
      rescue Exception => e
        @testRailUtility.postResult(104,e,5,@run)
        puts e
        raise e
      end
    end
  end

  #it 'should show Refresh and Close Button when Submit button is clicked but no record is checked' do

  #end


=begin
		it 'should Fill details on availability page' do
		    app.getDriver
		    .switchToAvaibiliy
		    .setPresetView(availabilityHash['scenario:1']['presetView'])
		    .setCity(availabilityHash['scenario:1']['city'])
		    .setUnitType(availabilityHash['scenario:1']['unitType'])
		    .showRecords(availabilityHash['scenario:1']['showRecords'])
		     sleep(5)
		     resResponce =  app.getDriver
		    .selectbuildings(availabilityHash['scenario:1']['buildings'])
		   # .clickToSubmit(availabilityHash['scenario:1']['buildings'],
		        #           availabilityHash['scenario:1']['city'],
		        #           availabilityHash['scenario:1']['showRecords'],
		          #         availabilityHash['scenario:1']['unitType'])
		    # Check for avaibility api responce return from page and the responce get back from call to api
		    #expect(resResponce[0]).to eq(resResponce[1])
	  	end
=end


  #it "should set the values on Availability Page" do
  #@objReservableAvailability.setAvailability()
  #end

=begin
	it "should Set Values in Availability page" do
		@objReservableAvailability.redirectToAvailability()
		puts "Inside Spec: #{@objReservableAvailability.getDriver.title}"
		#expect(@objReservableAvailability.getDriver.title).to eq "Contacts: Home ~ Salesforce - Unlimited Edition"
	end

	it "Save As Preset View, Submit and Save buttons should be disable when only city is selected" do
			@objReservableAvailability.setCity('Paris')
			expect(@objReservableAvailability.saveAsPresetViewButtonEnabled?()).to eq false
			expect(@objReservableAvailability.saveButtonEnabled?).to eq false	
			expect(@objReservableAvailability.submitButtonEnabled?).to eq false
	end
=end

  after(:all) {
    #@objReservableAvailability.recordDeletion()
    #salesforce.deleteRecords()
    @driver.quit
  }
end


=begin
it '' do
			@objReservableAvailability.setMinCapacity(@testRecords['scenario:5']['SetMinCapacity'][4])	#21
			@objReservableAvailability.setMaxCapacity(@testRecords['scenario:6']['SetMaxCapacity'][1])	#20
			#@objReservableAvailability.setMinCapacity(@testRecords['scenario:5']['SetMinCapacity'][6])	#19
		end

		it 'Should show error message for Invalid detail of Min Max Price Range on availability page' do
			@objReservableAvailability.setMinPriceRange(@testRecords['scenario:7']['setMinPriceRange'][1])	#2000
			@objReservableAvailability.setMaxPriceRange(@testRecords['scenario:8']['setMaxPriceRange'][2])	#1500
			@objReservableAvailability.setMinPriceRange(@testRecords['scenario:7']['setMinPriceRange'][3])	#1700
			expect(@objReservableAvailability.checkError()).to eq true
		end

=end
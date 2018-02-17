#Created By : Kishor Shinde
#Created Date : 28/12/2017
#Modified date :
require_relative '../../src/pageObjects/mergeOpportunitiesPage'
require "selenium-webdriver"
require "rspec"

describe MergeOpportunities do
	before(:all){
		@driver = Selenium::WebDriver.for :firefox
		@objMergeOpportunities = MergeOpportunities.new(@driver)
	}


	it "C151 : To check if opportunities is able to merge for admin profile." do
		puts "C151 : To check if opportunities is able to merge for admin profile."

		puts "checking Opportunity Merge button in opportunity list view"
		expect(@objMergeOpportunities.clickOn("Opportunity_Tab","Opportunity Merge").displayed?).to eq true

		puts "checking OpportunityMergePage title"
		@objMergeOpportunities.clickOn("Opportunity_Tab","Opportunity Merge").click
		#wait for page to load
		EnziUIUtility.wait(@driver,:id,"lightning",100)
		expect(@objMergeOpportunities.getDriver.title).to eq "Merge Opportunities"

		#checking no of record displyed in table and actual record in salesforce
		#if user profile admin and support table contans all opp having stage != merge

		puts "Checking actual record in salesforce and opportunities displayed in table"
		#expect(@objMergeOpportunities.NumberOfOpportunitiesInSalesforce() == @objMergeOpportunities.calculateNumberOfRows(false)).to eq true
		
		puts "Checking progress bar"
		expect(@objMergeOpportunities.getProgress).to eq "0%"

		puts "Checking error message when user does not select any of the opportunity from the opportunity Information page and clicks on the Next button."
		@objMergeOpportunities.searchText("test")
		EnziUIUtility.wait(@driver,nil,nil,10)
		expect(@objMergeOpportunities.clickNextWithoutSelectingOpportunity()).to eq "Select atleast two opportunities."
		@objMergeOpportunities.closeErrorMessage

		puts "Checking error message when user selects single opportunity from opportunity information page and click on next buttton."
		#select opportunity 1 and click on next
		EnziUIUtility.wait(@driver,nil,nil,10)
		#select opportunity 0
		@objMergeOpportunities.clickElement("checkbox:0")

		puts "Checking for opportunity selected"
		expect(@objMergeOpportunities.isSelected("checkbox:0")).to eq true

		expect(@objMergeOpportunities.clickNextBySelectingOpportunity()).to eq "Select atleast two opportunities."
		@objMergeOpportunities.closeErrorMessage

		@objMergeOpportunities.clickElement("checkbox:1")
		puts "Checking for opportunity selected"
		expect(@objMergeOpportunities.isSelected("checkbox:1")).to eq true
		
		numOfSelectedOpportunityOnFirstPage=@objMergeOpportunities.calculateNumberOfRows(true)

		puts "Click on next button"
		@objMergeOpportunities.clickElement("next")

		numberOfRowsOnSecondPage=@objMergeOpportunities.calculateNumberOfRows(false)

		puts "Checking SelectedOppFromFirstPage = OppOnSecondPage"
		expect(numOfSelectedOpportunityOnFirstPage == numberOfRowsOnSecondPage).to eq true

		puts "Checking title of table"
		expect(@objMergeOpportunities.getHeader).to eq "Select Primary Opportunity"
				
		puts "Checking progress bar on second page"
		expect(@objMergeOpportunities.getProgress).to eq "50%"
				
		puts "Checking error message when user does not select opportunity from primary opportunity page and click on merge buttton."
		expect(@objMergeOpportunities.clickMergeWithoutSelectingOpportunityAsPrimaryOpportunity()).to eq "Please select one opportunity as primary opportunity to merge."
		@objMergeOpportunities.closeErrorMessage
		
		puts "Checking error message when user selects multiple opportunity from primary opportunity page and click on merge buttton."
		EnziUIUtility.wait(@driver,nil,nil,2)
		@objMergeOpportunities.clickElement("checkbox:0")
		@objMergeOpportunities.clickElement("checkbox:1")
		@objMergeOpportunities.clickElement("next")
		EnziUIUtility.wait(@driver,nil,nil,2)
		expect(@objMergeOpportunities.clickMergeBySelectingTwoOpportunityAsPrimaryOpportunity()).to eq "You can select only one opportunity as primary opportunity to merge."
		@objMergeOpportunities.closeErrorMessage

		puts "Checking DeSelecting Opportunity"
		@objMergeOpportunities.clickElement("checkbox:1")
		EnziUIUtility.wait(@driver,nil,nil,2)
		expect(@objMergeOpportunities.isSelected("checkbox:1")).to eq false

		opportunityData = @objMergeOpportunities.getAllData(false)
		puts "Primary Opportunity"
		puts opportunityData["1"]["0"][1]
		puts "SEcondary Opportunity"
		puts opportunityData["1"]["1"][1]

		puts "Clicking on merge button"
		@objMergeOpportunities.clickElement("next")

		EnziUIUtility.wait(@driver,nil,nil,3)

		puts "checking confirmation message"
		expect(@objMergeOpportunities.getConfirmationMessage).to eq "Are you sure you want merge the selected opportunities ?"
				
						
	end
	after(:all){
		#@driver.quit
	}

	after(:each){
		
	
	}

end
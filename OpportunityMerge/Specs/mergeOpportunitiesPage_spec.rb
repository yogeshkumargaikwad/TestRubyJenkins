#Created By : Kishor Shinde
#Created Date : 28/12/2017
#Modified date :
require_relative '../PageObjects/mergeOpportunitiesPage'
require "selenium-webdriver"
require "rspec"


describe MergeOpportunities do
	before(:all){
		@driver = Selenium::WebDriver.for :chrome
		@driver.manage.window.maximize
		@objMergeOpportunities = MergeOpportunities.new(@driver)
	}


	it "C167 : To check if opportunities is able to merge for admin profile." do
		puts "C167 : To check if opportunities is able to merge for admin profile."
		opportunityTab = @objMergeOpportunities.getTab("Opportunity_Tab","Opportunity Merge")
		puts "checking Opportunity Merge button in opportunity list view"
		expect(opportunityTab.displayed?).to eq true
		puts "Clicking on Opportunity Tab"
		opportunityTab.click
		puts "checking OpportunityMergePage title"
		#wait for page to load
		EnziUIUtility.wait(@driver,:id,"lightning",120)
		expect(@objMergeOpportunities.getDriver.title).to eq "Merge Opportunities"

		#puts "Checking actual record in salesforce and opportunities displayed in table"
    	#puts @objMergeOpportunities.numberOfOpportunitiesInSalesforce()
    	#puts  @objMergeOpportunities.calculateNumberOfRows(false)
		#expect(@objMergeOpportunities.numberOfOpportunitiesInSalesforce() == @objMergeOpportunities.calculateNumberOfRows(false)).to eq true

		puts "Checking progress bar"
    	puts  @objMergeOpportunities.getProgress
		#expect(@objMergeOpportunities.getProgress).to eq "0%"

		@objMergeOpportunities.searchText("test_EnzigmaSoft")
		EnziUIUtility.wait(@driver,nil,nil,5)

		puts "Checking for opportunity 0 selected"
		@driver.execute_script("return arguments[0].parentNode.parentNode;" , @driver.find_element(:id ,'checkbox:0')).click
    	expect(@objMergeOpportunities.isSelected("checkbox:0")).to eq true

		puts "Checking for opportunity 1 selected"
    	@driver.execute_script("return arguments[0].parentNode.parentNode;" , @driver.find_element(:id ,'checkbox:1')).click
    	expect(@objMergeOpportunities.isSelected("checkbox:1")).to eq true

		numOfSelectedOpportunityOnFirstPage=@objMergeOpportunities.calculateNumberOfRows(true)
	    puts numOfSelectedOpportunityOnFirstPage
		puts "Click on next button"
		#EnziUIUtility.wait(@driver,nil,nil,10)
		puts @objMergeOpportunities.getElementByAttribute(:tag_name,"button","id","next").click
		EnziUIUtility.wait(@driver, :id, 'checkbox:1', 30)
    	numberOfRowsOnSecondPage=@objMergeOpportunities.calculateNumberOfRows(false)
		puts "number of opp on 2nd page"
		puts numberOfRowsOnSecondPage
		puts "Checking SelectedOppFromFirstPage = OppOnSecondPage"
		expect(numOfSelectedOpportunityOnFirstPage == numberOfRowsOnSecondPage).to eq true

		puts "Checking title of table"
		expect(@objMergeOpportunities.getHeader).to eq "Select Primary Opportunity"

		puts "Checking progress bar on second page"
		expect(@objMergeOpportunities.getProgress).to eq "50%"


		puts "Selecting opportunity 0 as primary opportunity"
		@driver.execute_script("return arguments[0].parentNode.parentNode;" , @driver.find_element(:id ,'checkbox:0')).click

		puts "Checking for opportunity 0 selected as Primary Opportunity"
		expect(@objMergeOpportunities.isSelected("checkbox:0")).to eq true

		opportunityData = @objMergeOpportunities.getAllData(false)
		puts "opportunityData"
		puts opportunityData.size
		puts "Primary Opportunity"
		puts opportunityData["1"]["0"][1]
		puts "Secondary Opportunity"
		puts opportunityData["1"]["1"][1]

		puts "Clicking on merge button"
		puts @objMergeOpportunities.getElementByAttribute(:tag_name,"button","id","next").click

		puts "checking confirmation message"
		expect(@objMergeOpportunities.getConfirmationMessage).to eq "Are you sure you want merge the selected opportunities ?"

		puts "click on yes"
		puts @objMergeOpportunities.getElementByAttribute(:tag_name,"button","title","Yes").click

		puts "checking successsfull merge message"
		expect(@objMergeOpportunities.getErrorMessage(:id,"divErrorToaster")).to eq "Opportunity has been merged successfully"
		puts "successsfull merge message checked"

		puts "Checking Status bar As 100%"
		expect(@objMergeOpportunities.getProgress).to eq "100%"

		EnziUIUtility.wait(@driver,:id,"contentWrapper",30)
		puts "Checking page title - After successfull merge operation"
		puts @objMergeOpportunities.getDriver.title
    puts "URL -After successfull merge operation"
    puts @driver.current_url()
		afterMergePrimary = @objMergeOpportunities.isOpportunityMerged(opportunityData["1"]["0"][1])
		puts "afterMergePrimary"
		puts afterMergePrimary

		afterMergeSecondary = @objMergeOpportunities.isOpportunityMerged(opportunityData["1"]["1"][1])
		puts "afterMergeSecondary"
		puts afterMergeSecondary

		puts "Checking Merged_Opportunity__c field on Merged opportunity"
		expect(afterMergeSecondary.fetch("Merged_Opprtunity__c")).to eq opportunityData["1"]["0"][1]

		puts "Checking Secondary opportunity Stage"
		expect(afterMergeSecondary.fetch("StageName")).to eq "Merged"

		puts "Checking Primary opportunity Building Interest"
		#expect(afterMergePrimary[2]).to eq (beforeMergePrimary[2] + beforeMergeSecondary[2] - 1)

		puts "Checking Primary opportunity Tours"
		#expect(afterMergePrimary[3]).to eq (beforeMergePrimary[3] + beforeMergeSecondary[3])
	end
	after(:all){
		#@driver.quit
	}
	after(:each){}
end
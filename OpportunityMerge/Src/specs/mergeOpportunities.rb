#Created By : Kishor Shinde
#Created Date : 28/12/2017
#Modified date :
require_relative '../../src/pageObjects/mergeOpportunitiesPage'
require "selenium-webdriver"
require "rspec"

describe MergeOpportunities do
	before(:all){
		@driver = Selenium::WebDriver.for :chrome
		@objMergeOpportunities = MergeOpportunities.new(@driver)
		#@objMergeOpportunities.createTestData(true,"1")
		#@objMergeOpportunities.createTestData(false,"3")
	}
	before(:each){	}

		context "Admin User" do
		before(:all){
			@objMergeOpportunities.setUser("1")
		}
		before(:each){	
		}
		it "T134 : To check if opportunities is able to merge for admin profile" do
			puts "------------------------------------------------------------------------------------------------"
			puts "T134 : To check if opportunities is able to merge for admin profile"

			puts "checking Opportunity Merge button in opportunity list view"
			expect(@objMergeOpportunities.clickOnTab("Opportunity_Tab","Opportunity Merge").displayed?).to eq true
			puts "button is present"

			puts "checking OpportunityMergePage title"
			@objMergeOpportunities.clickOnTab("Opportunity_Tab","Opportunity Merge").click

			#wait for page to load
			EnziUIUtility.wait(@driver,:id,"lightning",100)
			expect(@objMergeOpportunities.getDriver.title).to eq "Merge Opportunities"
			puts "Title Checked "

			puts "Checking actual record in salesforce and opportunities displayed in table"
			#puts @objMergeOpportunities.numberOfOpportunitiesInSalesforce("2")
			puts @objMergeOpportunities.calculateNumberOfRows(false)
			#expect(@objMergeOpportunities.numberOfOpportunitiesInSalesforce("2") == @objMergeOpportunities.calculateNumberOfRows(false)).to eq true
			puts "Record Checked "

			puts "Checking progress bar"
			expect(@objMergeOpportunities.getProgress).to eq "0%"
			puts "Progress bar checked "

			#puts "Checking error message when user does not select any of the opportunity from the opportunity Information page and clicks on the Next button."
			@objMergeOpportunities.searchText("test")
			EnziUIUtility.wait(@driver,nil,nil,5)

			#select opportunity 0
			@objMergeOpportunities.clickElement("checkbox:0")
			

			puts "Checking for opportunity selected"
			expect(@objMergeOpportunities.isSelected("checkbox:0")).to eq true
			puts "Record selected checked "

			puts "Checking for opportunity selected"
			@objMergeOpportunities.clickElement("checkbox:1")
			expect(@objMergeOpportunities.isSelected("checkbox:1")).to eq true
			puts "Record selected checked "

			numOfSelectedOpportunityOnFirstPage=@objMergeOpportunities.calculateNumberOfRows(true)

			puts "Click on next button"
			@objMergeOpportunities.clickElement("next")

			numberOfRowsOnSecondPage=@objMergeOpportunities.calculateNumberOfRows(false)

			puts "Checking SelectedOppFromFirstPage = OppOnSecondPage"
			expect(numOfSelectedOpportunityOnFirstPage == numberOfRowsOnSecondPage).to eq true
			puts "Number of record checked as selected from 1st page"

			puts "Checking title of table"
			expect(@objMergeOpportunities.getHeader).to eq "Select Primary Opportunity"
			puts "Header Of table checked"		

			puts "Checking progress bar on second page"
			expect(@objMergeOpportunities.getProgress).to eq "50%"
			puts "Header Of table checked"		
					
			@objMergeOpportunities.clickElement("checkbox:0")
			EnziUIUtility.wait(@driver,nil,nil,2)
			expect(@objMergeOpportunities.isSelected("checkbox:0")).to eq true

			opportunityData = @objMergeOpportunities.getAllData(false)
			puts "Primary Opportunity-->"
			puts opportunityData["1"]["0"][1]
			puts "SEcondary Opportunity-->"
			puts opportunityData["1"]["1"][1]
			beforeMergePrimary = @objMergeOpportunities.isOpportunityMerged(opportunityData["1"]["0"][1])
			puts "beforeMergePrimary"
			puts beforeMergePrimary
			beforeMergeSecondary = @objMergeOpportunities.isOpportunityMerged(opportunityData["1"]["1"][1])
			puts "beforeMergeSecondary"
			puts beforeMergeSecondary
			
			puts "Clicking on merge button"
			@objMergeOpportunities.clickElement("next")

			EnziUIUtility.wait(@driver,nil,nil,3)

			puts "checking confirmation message"
			expect(@objMergeOpportunities.getConfirmationMessage).to eq "Are you sure you want merge the selected opportunities ?"
			puts "Congirmation message checked"

			puts "click on yes"
			@objMergeOpportunities.selectChildBy(:class,"slds-modal__container",:tag_name,"button","Yes")

			puts "checking successsfull merge message"
			expect(@objMergeOpportunities.getErrorMessage(:id,"divErrorToaster")).to eq "Opportunity has been merged successfully"
			puts "successsfull merge message checked"
			puts "Checking Status bar As 100%"
			expect(@objMergeOpportunities.getProgress).to eq "100%"

			EnziUIUtility.wait(@driver,:id,"contentWrapper",30)
			puts "Checking page title - primary opportunity page"
			puts @objMergeOpportunities.getDriver.title

			afterMergePrimary = @objMergeOpportunities.isOpportunityMerged(opportunityData["1"]["0"][1])
			puts "afterMergePrimary"
			puts afterMergePrimary
			
			afterMergeSecondary = @objMergeOpportunities.isOpportunityMerged(opportunityData["1"]["1"][1])
			puts "afterMergeSecondary"
			puts afterMergeSecondary
			
			puts "Checking Merged_Opportunity__c field on Merged opportunity"
			expect(afterMergeSecondary[0]).to eq opportunityData["1"]["0"][1]

			puts "Checking Secondary opportunity Stage"
			expect(afterMergeSecondary[1]).to eq "Merged"

			puts "Checking Primary opportunity Building Interest"
			expect(afterMergePrimary[2]).to eq (beforeMergePrimary[2] + beforeMergeSecondary[2] - 1)

			puts "Checking Primary opportunity Tours"
			expect(afterMergePrimary[3]).to eq (beforeMergePrimary[3] + beforeMergeSecondary[3])

		end
		after(:all){
			puts "after all context"
		}
		after(:each){
			puts "after each context"
		}
		end	



		context "Non Admin User" do
		before(:all){
			@objMergeOpportunities.setUser("2")
		}
		before(:each){	
		}
		it "T134 : To check if opportunities is able to merge for Non admin profile" do
			puts "------------------------------------------------------------------------------------------------"
			puts "T134 : To check if opportunities is able to merge for Non admin profile"

			puts "checking Opportunity Merge button in opportunity list view"
			expect(@objMergeOpportunities.clickOnTab("Opportunity_Tab","Opportunity Merge").displayed?).to eq true
			puts "button is present"

			puts "checking OpportunityMergePage title"
			@objMergeOpportunities.clickOnTab("Opportunity_Tab","Opportunity Merge").click

			#wait for page to load
			EnziUIUtility.wait(@driver,:id,"lightning",100)
			expect(@objMergeOpportunities.getDriver.title).to eq "Merge Opportunities"
			puts "Title Checked "

			puts "Checking actual record in salesforce and opportunities displayed in table"
			#puts @objMergeOpportunities.numberOfOpportunitiesInSalesforce("2")
			puts @objMergeOpportunities.calculateNumberOfRows(false)
			#expect(@objMergeOpportunities.numberOfOpportunitiesInSalesforce("2") == @objMergeOpportunities.calculateNumberOfRows(false)).to eq true
			puts "Record Checked "

			puts "Checking progress bar"
			expect(@objMergeOpportunities.getProgress).to eq "0%"
			puts "Progress bar checked "

			#puts "Checking error message when user does not select any of the opportunity from the opportunity Information page and clicks on the Next button."
			@objMergeOpportunities.searchText("test")
			EnziUIUtility.wait(@driver,nil,nil,5)

			#select opportunity 0
			@objMergeOpportunities.clickElement("checkbox:0")
			

			puts "Checking for opportunity selected"
			expect(@objMergeOpportunities.isSelected("checkbox:0")).to eq true
			puts "Record selected checked "

			puts "Checking for opportunity selected"
			@objMergeOpportunities.clickElement("checkbox:1")
			expect(@objMergeOpportunities.isSelected("checkbox:1")).to eq true
			puts "Record selected checked "

			numOfSelectedOpportunityOnFirstPage=@objMergeOpportunities.calculateNumberOfRows(true)

			puts "Click on next button"
			@objMergeOpportunities.clickElement("next")

			numberOfRowsOnSecondPage=@objMergeOpportunities.calculateNumberOfRows(false)

			puts "Checking SelectedOppFromFirstPage = OppOnSecondPage"
			expect(numOfSelectedOpportunityOnFirstPage == numberOfRowsOnSecondPage).to eq true
			puts "Number of record checked as selected from 1st page"

			puts "Checking title of table"
			expect(@objMergeOpportunities.getHeader).to eq "Select Primary Opportunity"
			puts "Header Of table checked"		

			puts "Checking progress bar on second page"
			expect(@objMergeOpportunities.getProgress).to eq "50%"
			puts "Header Of table checked"		
					
			@objMergeOpportunities.clickElement("checkbox:0")
			EnziUIUtility.wait(@driver,nil,nil,2)
			expect(@objMergeOpportunities.isSelected("checkbox:0")).to eq true

			opportunityData = @objMergeOpportunities.getAllData(false)
			puts "Primary Opportunity-->"
			puts opportunityData["1"]["0"][1]
			puts "SEcondary Opportunity-->"
			puts opportunityData["1"]["1"][1]
			beforeMergePrimary = @objMergeOpportunities.isOpportunityMerged(opportunityData["1"]["0"][1])
			puts "beforeMergePrimary"
			puts beforeMergePrimary
			beforeMergeSecondary = @objMergeOpportunities.isOpportunityMerged(opportunityData["1"]["1"][1])
			puts "beforeMergeSecondary"
			puts beforeMergeSecondary
			
			puts "Clicking on merge button"
			@objMergeOpportunities.clickElement("next")

			EnziUIUtility.wait(@driver,nil,nil,3)

			puts "checking confirmation message"
			expect(@objMergeOpportunities.getConfirmationMessage).to eq "Are you sure you want merge the selected opportunities ?"
			puts "Congirmation message checked"

			puts "click on yes"
			@objMergeOpportunities.selectChildBy(:class,"slds-modal__container",:tag_name,"button","Yes")

			puts "checking successsfull merge message"
			expect(@objMergeOpportunities.getErrorMessage(:id,"divErrorToaster")).to eq "Opportunity has been merged successfully"
			puts "successsfull merge message checked"
			puts "Checking Status bar As 100%"
			expect(@objMergeOpportunities.getProgress).to eq "100%"

			EnziUIUtility.wait(@driver,:id,"contentWrapper",30)
			puts "Checking page title - primary opportunity page"
			puts @objMergeOpportunities.getDriver.title

			afterMergePrimary = @objMergeOpportunities.isOpportunityMerged(opportunityData["1"]["0"][1])
			puts "afterMergePrimary"
			puts afterMergePrimary
			
			afterMergeSecondary = @objMergeOpportunities.isOpportunityMerged(opportunityData["1"]["1"][1])
			puts "afterMergeSecondary"
			puts afterMergeSecondary
			
			puts "Checking Merged_Opportunity__c field on Merged opportunity"
			expect(afterMergeSecondary[0]).to eq opportunityData["1"]["0"][1]

			puts "Checking Secondary opportunity Stage"
			expect(afterMergeSecondary[1]).to eq "Merged"

			puts "Checking Primary opportunity Building Interest"
			expect(afterMergePrimary[2]).to eq (beforeMergePrimary[2] + beforeMergeSecondary[2] - 1)

			puts "Checking Primary opportunity Tours"
			expect(afterMergePrimary[3]).to eq (beforeMergePrimary[3] + beforeMergeSecondary[3])

		end
		after(:all){
			puts "after all context"
		}
		after(:each){
			puts "after each context"
		}
		end	
	after(:all){
		#@driver.quit
		#@objMergeOpportunities.deleteCreatedRecord
	}

	after(:each){	
	}

end
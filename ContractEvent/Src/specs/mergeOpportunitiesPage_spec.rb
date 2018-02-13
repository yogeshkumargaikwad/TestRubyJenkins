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

	it "C60 : To check Opportunity merge button is displayed in opportunity list view." do
		puts "C60 : Checking Opportunity merge button is displayed in opportunity list view."
		button = @objMergeOpportunities.clickOnTab("Opportunity_Tab","Opportunity Merge")
		expect(button.displayed?).to eq true

	end

	it "C61 : To check Merge opportunities page is displayed after clicking on Opportunity merge button" do
		puts "Clicking on Opportunity Merge button"
		@objMergeOpportunities.clickOnTab("Opportunity_Tab","Opportunity Merge").click
		puts " C61 : Checking Merge opportunities page title"
		expect(@objMergeOpportunities.getDriver.title).to eq "Merge Opportunities"
		puts " C61 : Checked"
	end
	
	it "check Page Table header" do
		puts ": Checking Table header"
		expect(@objMergeOpportunities.getHeader).to eq "Select Opportunities to merge"
		puts "Checked"
	end

	it "C90 : To check when selected count should be displayed as per the predefined count in the picklist value of merge opportunity page." do
		puts "C90 : Checking list of select page size as [5,10,20,50,100]"
		expect(@objMergeOpportunities.getSelectOptions(:id,"selectPageSize",:tag_name,"option")).to eq ["5","10","20","50","100"]
		puts " C90 : Checked"
	end

	it "progress bar" do
		puts "Checking progress bar"
		expect(@objMergeOpportunities.getProgress).to eq "0%"
	end

	it "C62 : To check proper header is displayed in Merge Opportunity page." do
		puts "C62 : Checking headers of table"
		expect(@objMergeOpportunities.getTableHeaders).to eq ["Select All" , "OPPORTUNITY ID","NAME","ACCOUNT NAME","STAGE","CLOSE DATE","SEGMENT"]
		puts " C62 : Checked"
	end

	it "C93: To check when user is at the first page, pagination first and previous button should be disabled." do		
			puts "C93 : Checking pagination button first and previous button should be disabled and Last and Next should enabled when when user is on first page"
			EnziUIUtility.wait(@driver,nil,nil,30)
			expect(@objMergeOpportunities.checkBtnEnabled("btnPrev")).to eq false
			expect(@objMergeOpportunities.checkBtnEnabled("btnFirst")).to eq false
			expect(@objMergeOpportunities.checkBtnEnabled("btnLast")).to eq true
			expect(@objMergeOpportunities.checkBtnEnabled("btnNext")).to eq true
			puts " C93 : Checked"
	end

	it "C98: To check when user is at the middle page, pagination first and previous, last and next button should be enabled." do		
			puts "C98 : Checking pagination button Prev, First, Last and Next should enabled when when user is on intermediate page"
			@objMergeOpportunities.clickElement("btnNext")
			EnziUIUtility.wait(@driver,nil,nil,30)
			expect(@objMergeOpportunities.checkBtnEnabled("btnPrev")).to eq true
			expect(@objMergeOpportunities.checkBtnEnabled("btnFirst")).to eq true
			expect(@objMergeOpportunities.checkBtnEnabled("btnLast")).to eq true
			expect(@objMergeOpportunities.checkBtnEnabled("btnNext")).to eq true
			puts " C98 : Checked"
	end

	it "C97:To check when user is at the last page, pagination last and next button should be disabled." do		
			puts "C97 : Checking pagination button Prev, First should enabled and Last and Next should disabled when when user is on last page"
			@objMergeOpportunities.clickElement("btnLast")
			EnziUIUtility.wait(@driver,nil,nil,20)
			expect(@objMergeOpportunities.checkBtnEnabled("btnPrev")).to eq true
			expect(@objMergeOpportunities.checkBtnEnabled("btnFirst")).to eq true
			expect(@objMergeOpportunities.checkBtnEnabled("btnLast")).to eq false
			expect(@objMergeOpportunities.checkBtnEnabled("btnNext")).to eq false
			puts " C97 : Checked"
	end


	it "check actual record in salesforce and opportunities displayed in table" do
		puts "Checking actual record in salesforce and opportunities displayed in table"
		expect(@objMergeOpportunities.NumberOfOpportunitiesInSalesforce() == @objMergeOpportunities.calculateNumberOfRows(false)).to eq true
		puts "Checked"
	end



	it "C66 : To check row count should be displayed as per the selected count in the Merge Opportunity page." do
		puts "C66 : Checking row count as per page size"
		expect(@objMergeOpportunities.getData(false).length == @objMergeOpportunities.getSelectedValue(:id,"selectPageSize",:tag_name,"option")).to eq true
		puts " C66 : Checked"
	end

	it "C68 : To check when user does not select any of the opportunity from the opportunity Information page and clicks on the Next button." do
			puts "C68 : Checking error message when user does not select any of the opportunity from the opportunity Information page and clicks on the Next button."
			@objMergeOpportunities.searchText("test")
			EnziUIUtility.wait(@driver,nil,nil,10)
			expect(@objMergeOpportunities.clickNextWithoutSelectingOpportunity()).to eq "Select atleast two opportunities."
			@objMergeOpportunities.closeErrorMessage
			puts "C68 : Checked"
	end	


	it "C69 :To check when user selects single opportunity or single opportunity is found at the opportunity information page and click on next buttton." do
		puts "C69 : Checking error message when user selects single opportunity from opportunity information page and click on next buttton."
		#select opportunity 1 and click on next
		EnziUIUtility.wait(@driver,nil,nil,10)
		#select opportunity 0
		expect(@objMergeOpportunities.clickNextBySelectingOpportunity()).to eq "Select atleast two opportunities."
		@objMergeOpportunities.closeErrorMessage
		puts "C69 : Checked"
	end

	it "C70 : To check when user selects opportunity from the opportunity information page and click on next button" do
		puts "C70 : To check when user selects opportunity from the opportunity information page and click on next button"
		EnziUIUtility.wait(@driver,nil,nil,10)
		puts "select opportunity 1"
		@objMergeOpportunities.clickElement("checkbox:1")
		puts "select opportunity 2"
		@objMergeOpportunities.clickElement("checkbox:2")
		numOfSelectedOpportunityOnFirstPage=@objMergeOpportunities.calculateNumberOfRows(true)
		puts "Clicking on next button"
		@objMergeOpportunities.clickElement("next")
		EnziUIUtility.wait(@driver,nil,nil,20)
		puts "Checking title of table"
		expect(@objMergeOpportunities.getHeader).to eq "Select Primary Opportunity"
		numberOfRowsOnSecondPage=@objMergeOpportunities.calculateNumberOfRows(false)
		puts "Checking number of rows as selected in previous page"
		expect(numOfSelectedOpportunityOnFirstPage == numberOfRowsOnSecondPage).to eq true
		puts "Checked"
	end

	it "C100 : To check when does not select multiple opportunities from the Select Primary Opportunity page and clicks on the Next button." do
		puts "Checking error message when user does not select opportunity from primary opportunity page and click on merge buttton."
		expect(@objMergeOpportunities.clickMergeWithoutSelectingOpportunityAsPrimaryOpportunity()).to eq "Please select one opportunity as primary opportunity to merge."
		@objMergeOpportunities.closeErrorMessage
		puts "C100 : Checked"
	end

	it "C99:To check when user selects multiple opportunities from the Select Primary Opportunity page and clicks on the Next button." do
		puts "Checking error message when user selects multiple opportunity from primary opportunity page and click on merge buttton."
		expect(@objMergeOpportunities.clickMergeBySelectingTwoOpportunityAsPrimaryOpportunity()).to eq "You can select only one opportunity as primary opportunity to merge."
		@objMergeOpportunities.closeErrorMessage
		puts "C99 : Checked"
	end

	it "C71 : To check when user selects opportunity from the opportunity information page and click on next button." do
		puts "C71 : Checking progress bar on second page"
		expect(@objMergeOpportunities.getProgress).to eq "50%"
		puts "C71 : Checked"
	end
=begin
			it "C72 : To check when user selects single opportunity from the select primary opportunity page and click on the merge button." do
				puts "C72 : Checking for window of confirmation will be displayed."
				puts "selecting opportunity 0 as primary opportunity"
				@objMergeOpportunities.clickElement("checkbox:1")

				puts "clicking on Merge button"
				@objMergeOpportunities.clickElement("next")

				puts "checking confirmation message"
				expect(@objMergeOpportunities.getConfirmationMessage).to eq "Are you sure you want merge the selected opportunities ?"

				puts "closing confirmation message by clicking on 'No' button"
				EnziUIUtility.wait(@driver,nil,nil,50)
				#EnziUIUtility.selectChildByText(@driver,:class,"slds-modal slds-fade-in-open",:tag_name,"button","Yes")
				@objMergeOpportunities.selectChildBy(:class,"slds-modal__container",:tag_name,"button","No")

				puts "Checking page after clicking on No"
				expect(@objMergeOpportunities.getTableHeader).to eq "Select Primary Opportunity"

			end
=end

			it "C72 : To check when user selects single opportunity from the select primary opportunity page and click on the merge button." do
				puts "C72 : Checking opportunity merge successsfully"
=begin
				EnziUIUtility.wait(@driver,nil,nil,15)
				@objMergeOpportunities.searchText("test")
				EnziUIUtility.wait(@driver,nil,nil,10)
				@driver.find_element(:id ,"checkbox:1").click
				EnziUIUtility.wait(@driver,nil,nil,5)
				@driver.find_element(:id ,"checkbox:2").click
				#EnziUIUtility.wait(@driver,nil,nil,5)
				#@driver.find_element(:id ,"checkbox:3").click
				EnziUIUtility.wait(@driver,nil,nil,5)
				@driver.find_element(:id ,"next").click
=end
				EnziUIUtility.wait(@driver,nil,nil,5)
				#select opportunity 0 as primary opportunity by deselecting opportunity 1
				@objMergeOpportunities.clickElement("checkbox:1")
				
				#primaryOpportunity = @objMergeOpportunities.getAllData(true)

				puts "Opportunity to merge"
				opportunityData = @objMergeOpportunities.getAllData(false)
				#puts opportunityData
				puts "Primary Opportunity"
				puts opportunityData["1"]["0"][1]

				puts "SEcondary Opportunity"
				puts opportunityData["1"]["1"][1]
				#puts opportunityData["1"]["2"][1]

				puts "Clicking on merge button"
				EnziUIUtility.wait(@driver,nil,nil,7)
				@objMergeOpportunities.clickElement("next")

				EnziUIUtility.wait(@driver,nil,nil,3)
				puts "checking confirmation message"
				expect(@objMergeOpportunities.getConfirmationMessage).to eq "Are you sure you want merge the selected opportunities ?"

				puts "click on yes"
				@objMergeOpportunities.selectChildBy(:class,"slds-modal__container",:tag_name,"button","Yes")

				puts "checking successsfull merge message"
				expect(@objMergeOpportunities.getErrorMessage(:id,"divErrorToaster")).to eq "Opportunity has been merged successfully"
				
				puts "Checking Status bar As 100%"
				expect(@objMergeOpportunities.getProgress).to eq "100%"
				#expect(@objMergeOpportunities.getErrorMessage(:id,"lightning",:tag_name,"h2","Opportunity has been merged successfully")).to eq "Opportunity has been merged successfully"
				#expect(@objMergeOpportunities.getProgress).to eq "100%"


				EnziUIUtility.wait(@driver,:id,"contentWrapper",30)
				puts "Checking page title - primary opportunity page"
				puts @objMergeOpportunities.getDriver.title
				#expect(@objMergeOpportunities.getDriver.title).to eq "Opportunity"

				#puts "Checking merged opportunity"

				#puts "Primary Opportunity"
				#puts @objMergeOpportunities.isOpportunityMerged("#{opportunityData["1"]["0"][1]}")

				puts "Checking Secondary opportunity Stage"
				puts @objMergeOpportunities.isOpportunityMerged("#{opportunityData["1"]["1"][1]}")[1]
				#expect(@objMergeOpportunities.isOpportunityMerged("#{opportunityData["1"]["1"][1]}")[1]).to eq "Merged"

				#puts "Secondary opportunity2"
				#puts @objMergeOpportunities.isOpportunityMerged("#{opportunityData["1"]["2"][1]}")
				#expect(@objMergeOpportunities.isOpportunityMerged("#{opportunityData["1"]["1"][1]}"))
			end	
	after(:all){
		#@driver.quit
	}

	after(:each){
		
	
	}

end
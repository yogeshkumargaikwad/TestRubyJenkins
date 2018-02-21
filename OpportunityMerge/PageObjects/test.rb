require "selenium-webdriver"
require 'salesforce'
require 'selenium-webdriver'
require 'yaml'
require 'json'

@driver = Selenium::WebDriver.for :chrome
@driver.manage.window.maximize




#sObjectRecordsJson = File.read("../testData/testRecords.json")
#@sObjectRecords = JSON.parse(sObjectRecordsJson)
@sfBulk = Salesforce.login('kishor.shinde@wework.com.qaauto','Anujgagare@525255',true)
@driver.get "https://test.salesforce.com/login.jsp?pw=Anujgagare@525255&un=kishor.shinde@wework.com.qaauto"




@driver.find_element(:id, "Opportunity_Tab").click

span = @driver.find_element(:class, "fBody")
span.find_element(:tag_name, "input").click

child = @driver.find_elements(:tag_name, "input")
child.each do |option|
  if option.attribute("value") == "Opportunity Merge" then
    option.click
    break
  end
end



@driver.execute_script("return arguments[0].parentNode.parentNode;" , @driver.find_element(:id ,'checkbox:1')).click
@driver.execute_script("return arguments[0].parentNode.parentNode;" , @driver.find_element(:id ,'checkbox:0')).click




elements = @driver.find_elements(:tag_name, "button")
elements.each do |element|
  if element.attribute("id") != nil then
    if element.attribute("id").include? "next" then
      element.click
      break
    end
  end
end


@driver.execute_script("return arguments[0].parentNode.parentNode;" , @driver.find_element(:id ,'checkbox:0')).click


elements = @driver.find_elements(:tag_name, "button")
elements.each do |element|
  if element.attribute("title") != nil then
    if element.attribute("title").include? "No" then
      @driver.execute_script("arguments[0].style.visibility='visible';" ,element).click
      break
    end
  end
end


elements = @driver.find_elements(:tag_name, "button")
elements.each do |element|
  if element.attribute("title") != nil then
    if element.attribute("title").include? "Yes" then
      element.click
      break
    end
  end
end




elements = @driver.find_elements(:tag_name, "td")
elements.each do |element|
  if element.attribute("data-aura-rendered-by") != nil then
    if element.attribute("data-aura-rendered-by").include? "78:118;a" then
      element.click
      break
    end
  end
end


elements = @driver.find_elements(:tag_name, "td")
elements.each do |element|
  if element.attribute("data-label") != nil then
    if element.attribute("data-label").include? "Select Row" then
        element.size
        break
    end
  end
end

elements = @driver.find_elements(:tag_name, "td")
count = 0
elements.each do |element|
  if element.attribute("data-label") != nil then
    if element.attribute("data-label").include? "Select Row" then
      if count == 1
      puts element.size
      break
      end
    end
  end
end


#for close error
elements = @driver.find_elements(:tag_name, "button")
elements.each do |element|
  if element.attribute("id") != nil then
    if element.attribute("id").include? "divErrorToaster:btnClose" then
      element.click
      break
    end
  end
end



#puts "Checking error message when user does not select any of the opportunity from the opportunity Information page and clicks on the Next button."
#@objMergeOpportunities.getElementByAttribute(:tag_name,"button","id","next").click
#puts @objMergeOpportunities.getErrorMessage(:id,"divErrorToaster")
#expect(@objMergeOpportunities.getErrorMessage(:id,"divErrorToaster")).to eq "Select atleast two opportunities."
#@objMergeOpportunities.closeErrorMessage

#puts "Checking error message when user selects single opportunity from opportunity information page and click on next buttton."
#
# #puts @objMergeOpportunities.getElementByAttribute(:tag_name,"button","id","next").click
#puts @objMergeOpportunities.getErrorMessage(:id,"divErrorToaster")

#expect(@objMergeOpportunities.getErrorMessage(:id,"divErrorToaster")).to eq "Select atleast two opportunities."
#puts @objMergeOpportunities.closeErrorMessage
#puts @objMergeOpportunities.getElementByAttribute(:tag_name,"button","id","next").click
#puts @objMergeOpportunities.clickElement("checkbox:1")
#puts @objMergeOpportunities.getElementByAttribute(:tag_name,"td","data-aura-rendered-by","365:118;a").click




#puts "Checking error message when user does not select opportunity from primary opportunity page and click on merge buttton."
#expect(@objMergeOpportunities.clickMergeWithoutSelectingOpportunityAsPrimaryOpportunity()).to eq "Please select one opportunity as primary opportunity to merge."
#@objMergeOpportunities.closeErrorMessage

#puts "Checking error message when user selects multiple opportunity from primary opportunity page and click on merge buttton."
#EnziUIUtility.wait(@driver,nil,nil,2)

#@driver.execute_script("return arguments[0].parentNode.parentNode;" , @driver.find_element(:id ,'checkbox:0')).click
#@driver.execute_script("return arguments[0].parentNode.parentNode;" , @driver.find_element(:id ,'checkbox:1')).click
#puts @objMergeOpportunities.getElementByAttribute(:tag_name,"button","id","next").click
#EnziUIUtility.wait(@driver,nil,nil,2)
#expect(@objMergeOpportunities.clickMergeBySelectingTwoOpportunityAsPrimaryOpportunity()).to eq "You can select only one opportunity as primary opportunity to merge."
#@objMergeOpportunities.closeErrorMessage

#puts "Checking DeSelecting Opportunity"
#@driver.execute_script("return arguments[0].parentNode.parentNode;" , @driver.find_element(:id ,'checkbox:1')).click
#EnziUIUtility.wait(@driver,nil,nil,2)
#expect(@objMergeOpportunities.isSelected("checkbox:1")).to eq false




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



parent = @driver.execute_script("return arguments[0].parentNode.parentNode;" , @driver.find_element(:id ,'checkbox:1'))


elements = @driver.find_elements(:tag_name, "input")
elements.each do |element|
  if element.attribute("id") != nil then
    if element.attribute("id").include? "checkbox:1" then
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
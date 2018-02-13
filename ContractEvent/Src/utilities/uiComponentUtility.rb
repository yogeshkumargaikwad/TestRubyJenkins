# Created By: Amol Darekar
# Created Date: 28th Aug 2017
# Purpose: This class contains definition for generic functions use by all classes
# Issue no:
require 'selenium-webdriver'
require 'yaml'
require_relative '../pageObjects/home'
require_relative '../../src/utilities/salesforceUtility'
class UIComponentUtility < SalesforceUtility
  #Globle variable accessible in a class which override 'AbstractPage' class
  @@driver = nil
  @@mainWindow = nil
  @@windowToSwithch = nil
  @@sfConnect = nil
  @@uiCompUtility = nil
  @@uiUtilityObj = Hash.new
  #@@sfRecordsMap = Hash.new

  #define a constructor
  def initialize(driver)
    @@driver = driver
  end

  def initializeAbstractObj(obj)
   # @@objAbstract = obj
  end

  #Use: This function navigate to root url
  def navigateToAppRoot
    config_data = YAML.load(File.open('..\..\src\config.yaml'))
    @@driver.navigate.to('https://test.salesforce.com/?un='+config_data[:credentials][:username]+'&pw='+config_data[:credentials][:password])
    @@uiCompUtility = self
    #return HomePage.new(@@driver)
  end

  def navigateToUrl(url)
    @@driver.navigate.to url
  end

  #Use: This function returns the object of availability page
  def getDriver
    return AvailabilityPage.new(@@driver)
  end

  #Use: This function is use to get reference of ruby class
  #Parameters: name = This is name of the page object whose related class reference need to return by this function
  #Example: getPageObject('SalesConsole')
  def getPageObject(name)
    if name == 'salesConsole'
         #@@mainWindow = @@driver.window_handles
         self.wait(:id,'scc_widget_Inbound_Call_button',20)
         return  SalesConsoleController.new(@@driver)
    elsif name == 'availability'
         return AvailabilityPage.new(@@driver)
    elsif name == 'ManageTours'
         return ManageTours.new(@@driver)
    elsif name == 'LeadDetails'
      return LeadDetails.new(@@driver)
    end
  end

  #Use: This function close the current browser
  def quit
    #@@driver.quit
  end

  #Use: This function print the page title
  def getpageTitle
    return  @@driver.title
  end

  #Use: This function click the html element
  #Parameters: findBy: use to find element using id,name,class,xpath
  #            elementIdentification: use to send name(id,name,class,xpath) to find element
  #Example: clickElement(:id,'btnSubmit')
  def clickElement(findBy,elementIdentification)
    @@driver.execute_script("arguments[0].scrollIntoView();" , @@driver.find_element(findBy ,elementIdentification))
    @@driver.find_element(findBy ,elementIdentification).click
  end

  #Use: This function use to set value of html element
  #Parameters: findBy: use to find element using id,name,class,xpath
  #            elementIdentification: use to send name(id,name,class,xpath) to find element
  #Example: setValue(:id,'txtMinVal',20)
  def setValue(findBy,elementIdentification,val)
    @@driver.find_element(findBy,elementIdentification).send_key val
  end

  def getValue(findBy,elementIdentification)
    return @@driver.find_element(findBy,elementIdentification).attribute('value')
  end

  #Use: This function use to wait code to execute till element gets created on page or page contains gets loaded
  #Parameters: findBy: use to find element using id,name,class,xpath
  #            elementIdentification: use to send name(id,name,class,xpath) to find element
  #            waittime: Time till wail for element to load
  #Example: wait(:id,'txtMinVal',20)
  def wait(findBy,elementIdentification,waitTime)
    if elementIdentification != nil then
      @wait = Selenium::WebDriver::Wait.new(:timeout => waitTime)
      @wait.until {@@driver.find_element(findBy ,elementIdentification)}
    else
      sleep(waitTime)
    end
  end

  #Use: This function use to close current window
  def closeWindow
    @@driver.close()
    @@driver.switch_to.window(@@mainWindow)
  end

 #Use: Switch element between frames
  def switchToFrame(frameName)
    @@driver.switch_to.frame(frameName)
  end

  #Use: This function is use to switch to frame if it's name not known.
  #     This function first get the available frames and then swithc to each frame till it does not find element available on frame
  def switchToFrames(findBy,elementIdentification)
    lstIframes = @@driver.find_elements(:tag_name,'iframe')
    lstIframes.each do|fr|
      if(fr.displayed? == true)
        @@driver.switch_to.frame(fr)
        if((@@driver.find_elements(findBy,elementIdentification).count > 0))
          break
        else
          @@driver.switch_to.window(allWindows[0])
        end
      end
    end
  end



  #Use: This function use to wait code to execute till element gets created on page or page contains gets loaded
  #Parameters: findBy: Use to find element using id,name,class,xpath
  #            parentElementId: Use to send name(id,name,class,xpath) to find element
  #            childElementTagName: childElement tag from which we need to select the value/option
  #            optionToSelect: It is option need to select from dropdown
  #Example: selectOption(':id','selectid','Default view')
  def selectOption(findBy,parentElementId,childElementTagName,optionToSelect)
    #Get the select element
    select = @@driver.find_element(findBy,parentElementId)
    #Get all the options for this element
    all_options = select.find_elements(:tag_name, childElementTagName)
    #select the options
    all_options.each do |option|
      if option.text == optionToSelect then
       option.click
        break
       end
      end
  end

  #Use:This function is use to switch driver control from main window to Availability browser window
  def switchToWindow(titleName,pageObjectName)
    @@uiCompUtility.wait(nil,nil,5)
    #Get all currnt open window
    allWindows = @@driver.window_handles
        #Find any new window open
        allWindows.each do |window|
          #if isMainWindow && @@mainWindow != window then
            @@driver.switch_to.window(window)
            if(titleName == @@driver.title) then
              break
            end
         # end #End of @@mainWindow if
        end #end of forEach for allWindows
    @@uiCompUtility.wait(nil,nil,5)
    #return self.getPageObject(pageObjectName)#AvailabilityPage.new(@@driver)
  end

  def getMainWindow(pageObjectName)
    @@mainWindow = @@driver.window_handles
    return self.getPageObject(pageObjectName)
  end

  def getBaseUrl
       urlArr = @@driver.current_url.split('/')
      @@uiUtilityObj.store('baseUrl',urlArr[0]+"//"+urlArr[2]+"/")
  end

  def inlineEdit(findBy,elementIdentification,value)
    @@driver.action.double_click(@@driver.find_element(findBy,elementIdentification)).perform
  end

  def getButtons
    buttonHeader = @@driver.find_element(:id,'topButtonRow')
    allButtons = buttonHeader.find_elements(:tag_name,'input')

    allButtons.each do |btn|
      if(btn.displayed?)
        puts btn.attribute('value')
      end
    end
  end

  def getELementWithFocus(findBy,elementIdentification)
    ele = @@driver.find_element(findBy ,elementIdentification)
    @@driver.execute_script("arguments[0].scrollIntoView();" , @@driver.find_element(findBy ,elementIdentification))
    return @@driver.find_element(findBy ,elementIdentification)
  end

  def switch_to_classic
    cur_url = @@driver.current_url
    if cur_url.include?'lightning.force.com'
      @@driver.find_element(:class,'profileTrigger').click
      @@driver.find_element(:class,'oneUserProfileCard').find_element(:link_text,'Switch to Salesforce Classic').click
    end
  end

  def switch_to_lightning
    curUrl = @@driver.current_url
    if curUrl.include?'my.salesforce.com'
      @@driver.find_element(:id,'userNavLabel').click
      @@driver.find_element(:id,'userNav-menuItems').find_element(:link_text,'Switch to Lightning Experience').click
    end
  end

  def clearValue(findBy,elementIdentification)
    @@driver.find_element(findBy,elementIdentification).clear
  end

end
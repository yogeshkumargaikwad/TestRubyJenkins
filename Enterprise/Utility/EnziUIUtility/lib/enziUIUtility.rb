class EnziUIUtility
  def initialize()
    #puts @driver.title
  end

  #Use: This function print the page title
  def self.getPageTitle(driver)
    puts driver.title
  end

  #Use: This function use to set value of html element
  #Parameters: findBy: use to find element using id,name,class,xpath
  #            elementIdentification: use to send name(id,name,class,xpath) to find element
  #Example: setValue(:id,'txtMinVal',20)
  def self.setValue(driver,findBy,elementIdentification,val)
    driver.find_element(findBy,elementIdentification).send_keys val
  end
   #Use: This function use to open a visualforce page
   #Example: setValue('contactDetailPage')
  def self.navigateToUrl(driver,url)
     driver.navigate.to url
  end

  #Use: This function click the html element
  #Parameters: findBy: use to find element using id,name,class,xpath
  #            elementIdentification: use to send name(id,name,class,xpath) to find element
  #Example: clickElement(:id,'btnSubmit')
  def self.clickElement(driver,findBy,elementIdentification)
    driver.execute_script("arguments[0].scrollIntoView();" , driver.find_element(findBy ,elementIdentification))
    driver.find_element(findBy ,elementIdentification).click
  end


  def self.getValue(driver,findBy,elementIdentification)
    return driver.find_element(findBy,elementIdentification).attribute('value')
  end

  #Use: This function use to wait code to execute till element gets created on page or page contains gets loaded
  #Parameters: findBy: Use to find element using id,name,class,xpath
  #            parentElementId: Use to send name(id,name,class,xpath) to find element
  #            childElementTagName: childElement tag from which we need to select the value/option
  #            optionToSelect: It is option need to select from dropdown
  #Example: selectOption(':id','selectid','Default view')
  def self.selectOption(driver,findBy,parentElementId,optionToSelect)#removed childElementTagName ultimately we are finding by options
    #Get the select element
    select = driver.find_element(findBy,parentElementId)
    #Get all the options for this element
    all_options = select.find_elements(:tag_name, "option")
    #select the options
    all_options.each do |option|
      if option.text == optionToSelect then
       option.click
        break
       end
      end
  end
  def self.selectChild(driver,findBy,parentElementId,textToselect,childTabName)
    #Get the select element
    puts "In select child by text"
    childs = Array.new
    parent = driver.find_element(findBy,parentElementId)
    #Get all the options for this element
    all_child = parent.find_elements(:tag_name, "#{childTabName}")
    #select the options
    all_child.each do |child|
      puts child.text
      if textToselect != nil then
        if child.text == textToselect then
          puts "text found"
          child.click
        break
       end
     else
      childs.push(child)
     end
    end
    return childs
  end
   #Use:This function is use to switch driver control from main window to Availability browser window
  def self.switchToWindow(driver,titleName)
    self.wait(driver,nil,nil,5)
    #Get all currnt open window
    allWindows = driver.window_handles
        #Find any new window open
        allWindows.each do |window|
          #if isMainWindow && @@mainWindow != window then
            driver.switch_to.window(window)
          	puts driver.title
            if(titleName == driver.title) then
              break
            end
         # end #End of @@mainWindow if
        end #end of forEach for allWindows
    self.wait(driver,nil,nil,5)
  end


  #Use: This function use to wait code to execute till element gets created on page or page contains gets loaded
  #Parameters: findBy: use to find element using id,name,class,xpath
  #            elementIdentification: use to send name(id,name,class,xpath) to find element
  #            waittime: Time till wail for element to load
  #Example: wait(:id,'txtMinVal',20)
  def self.wait(driver,findBy,elementIdentification,waitTime)
    if elementIdentification != nil then
      wait = Selenium::WebDriver::Wait.new(:timeout => waitTime)
      wait.until {driver.find_element(findBy ,elementIdentification)}
    else
      sleep(waitTime)
    end
  end

  #Use: This function close the current browser
  def self.quit(driver)
    driver.quit
  end

  def self.closeWindow(driver)
    driver.close()
    #driver.switch_to.window(mainWindow)
  end

  def self.switchToDefault(driver)
  	#driver.switch_to.default_content
  	driver.switch_to.window((driver.window_handles)[0])
  end


 #Use: Switch element between frames
  def self.switchToFrame(driver,frameName)
    driver.switch_to.frame(frameName)
  end

  #Use: This function is use to switch to frame if it's name not known.
  #     This function first get the available frames and then swithc to each frame till it does not find element available on frame
  def self.switchToFrames(driver,findBy,elementIdentification)
    lstIframes = driver.find_elements(:tag_name,'iframe')
    lstIframes.each do|fr|
      if(fr.displayed? == true)
        driver.switch_to.frame(fr)
        if((driver.find_elements(findBy,elementIdentification).count > 0))
          break
        else
          driver.switch_to.window(allWindows[0])
        end
      end
    end
  end

 def self.getBaseUrl(driver)
       urlArr = driver.current_url.split('/')
       return (urlArr[0]+"//"+urlArr[2]+"/")
 end

  def self.getElementWithFocus(driver,findBy,elementIdentification)
    ele = driver.find_element(findBy ,elementIdentification)
    driver.execute_script("arguments[0].scrollIntoView();" , driver.find_element(findBy ,elementIdentification))
    return driver.find_element(findBy ,elementIdentification)
  end

 end



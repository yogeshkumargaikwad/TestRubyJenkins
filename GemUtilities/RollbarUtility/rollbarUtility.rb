#Created By   : Pragalbha Mahajan
#Created Date : 23/02/2018
#Modified date:

require 'rollbar'

Rollbar.configure do |config|
  config.access_token = "7f8ce076a7cd4f569b7dc0ebf4bdb12e"
  #config.endpoint = 'https://api-alt.rollbar.com/api/1/item/'
  config.enabled = true
  config.environment = "sandbox"
  config.verify_ssl_peer = false

  # Other Configuration Settings
  #config.custom_data_method = lambda { { :Id => "", :Title => ""} }
end

class RollbarUtility
	def postRollbarData(id, title, passedExpects)
		Rollbar.configure do |config| 
        	config.custom_data_method = lambda { { :Id => id, :Title => title, :PassExpects => passedExpects}}
      	end
	end

	def addLog(logMessage, specId = nil)
	    puts logMessage
	    
	    if specId != nil
	      @@sId = specId
	      @@logHash = Hash.new()
	      @@logHash.store(specId, logMessage)
	    else
	      puts "Inside else: #{@@logHash}"
	      @@logHash[@@sId] = @@logHash[@@sId]+"\n"+logMessage
	    end
	    puts @@logHash
	    return @@logHash
  	end
end
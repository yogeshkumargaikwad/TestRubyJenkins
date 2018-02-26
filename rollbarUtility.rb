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
end
#Created By : Monika Pingale
#Created Date : 18th Jan 2018
#Purpose: This class has methods to test salesforce rest service url's
#Modified date :
require 'httparty'
require 'yaml'
class SfRESTService
  @@response = nil
  @@postedData = nil
  @@credentails = nil
  def self.loginRequest
    @@credentails = YAML.load_file('credentials.yaml')
    data = {"grant_type"=>@@credentails['QAAuto']['grant_type'],"client_id"=>@@credentails['QAAuto']['client_id'],"client_secret"=>@@credentails['QAAuto']['client_secret'], "username"=>@@credentails['QAAuto']['username'],"password"=>"#{@@credentails['QAAuto']['password']}"}
    @@response = HTTParty.post("https://test.salesforce.com/services/oauth2/token",
                              :body => data,
                              :headers => {"Content-Type":'application/x-www-form-urlencoded'} , verify: false)
     @@response
  end

  def self.getData(id,serviceUrl,loggedIn)
    if !loggedIn then
       @@response = SfRESTService.loginRequest
    end
    url = @@response['instance_url'] + "#{serviceUrl}/#{id}"
    getResponse = HTTParty.get(url,:headers => {"Content-Type":"application/json","Authorization" => "Bearer #{ @@response['access_token']}"} , verify: false)
    return getResponse
  end

  def self.postData(data,serviceUrl,loggedIn) 
    if !loggedIn then
       @@response = SfRESTService.loginRequest
    end
    url = "#{@@response['instance_url']}#{serviceUrl}"
    postResponse = HTTParty.post(url,:body => data,:headers => {"Content-Type":"application/json","Authorization" => "Bearer #{@@response['access_token']}"} , verify: false)
    puts postResponse
      @@postedData = postResponse['result']
    return postResponse
  end
end
#SfRESTService.loginRequest
#puts SfRESTService.postData('',"/services/apexrest/Tour",false)

#puts SfRESTService.postData('a0R3D00000110e0',"/services/apexrest/Tour",false)['tour_id']
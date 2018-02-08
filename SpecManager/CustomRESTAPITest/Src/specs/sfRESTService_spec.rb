#Created By : Monika Pingale
#Created Date : 18th Jan 2018
#Purpose: This class contains specs related to salesforce rest web service
#Modified date :
require "rspec"
require_relative "../../Src/objects/sfRESTService.rb"
require_relative "../utilities/EnziTestRailUtility/lib/EnziTestRailUtility.rb"
describe SfRESTService do
	before(:all){	
		testDataFile = File.open("../testData/testData.json", "r")
		testDataInJson = testDataFile.read()
		@testData = JSON.parse(testDataInJson) 
		@sfRESTService = SfRESTService.new()
		@testRailUtility = EnziTestRailUtility::TestRailUtility.new
	}
	it "check post request" do
		@getResponse = SfRESTService.postData(''+@testRailUtility.getCase(344)['custom_steps_separated'][0]['expected'],"#{@testData['ServiceUrls'][0]['tour']}",false)
		expect(@getResponse['success']).to be true
		expect(@getResponse['result']).to_not eql nil
		testRailUtility.postResult(344,"Result for case 344 is #{@getResponse['success']}",1)
	end
	it "check get request" do 
		postResponse = SfRESTService.getData(SfRESTService.class_variable_get(:@@postedData).delete('"'),"#{@testData['ServiceUrls'][0]['tour']}",false)
		expect(postResponse['success']).to be true
		expect(postResponse.parsed_response['result']['tour_id']).to_not eql nil
	end
end
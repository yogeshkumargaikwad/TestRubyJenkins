require 'yaml'
require_relative File.expand_path('',Dir.pwd)+'/ContractEvent/src/utilities/EnziTestRailUtility/lib/testrail/testrail.rb' 
module EnziTestRailUtility
	class TestRailUtility

 		def initialize(username,password)
   		@client = TestRail::APIClient.new('https://enzigma.testrail.io/')
   		@client.user =  username
   		@client.password = password
 		end

 		def getCase(caseId)
   		url = "get_case/#{caseId}"
   		return @client.send_get(url)
		end

 		def getCases(projectId, suiteId)
   		url = "get_cases/#{projectId}/&suite_id=#{suiteId}"
   		return @client.send_get(url)
 		end

 		def getSuite(suiteId)
   		url = "get_suite/#{suiteId}"
   		return @client.send_get(url)
 		end

 		def getSuites(projectId)
   		url = "get_suites/#{projectId}"
   		return @client.send_get(url)
 		end

      def getSuitByName(projectId,suitName)    
         suitJSON = getSuites(projectId)
         index = 0
         until suitJSON[index] == nil do
            if suitJSON[index]["name"] == suitName then 
               return suitJSON[index]["id"]
            end
            index +=1
         end
      end

      def getProjectByName(projectName)    
         arrProject = getProjects()
         index = 0
         id = nil
         until arrProject[index] == nil do
            if arrProject[index]["name"] == projectName.to_s then 
               id = arrProject[index]["id"]
               break
            end
            index +=1
         end
         return id
      end

 		def getProject(projectId)
   		url = "get_project/#{projectId}"
   		return @client.send_get(url)
 		end

 		def getProjects()
   		return @client.send_get('get_projects')
   		
 		end
      #StatusId ::
         #1  Passed
         #2  Blocked
         #3  Untested (not allowed when adding a result)
         #4  Retest
         #5  Failed
      def postResult(caseId,comment,statusId,testRunId)
         url = "add_result_for_case/#{testRunId}/#{caseId}"
         puts url
         @client.send_post(url, { :status_id => statusId, :comment => "#{comment}" })
      end

      def addRun(test_run_name,projectId,suiteId)
         @client.send_post("add_run/#{projectId}", {"suite_id": "#{suiteId}","name": "#{test_run_name}- #{Time.now.asctime}","include_all": true})
      end

      def getRuns(suitId,sectionId,projectId)
         @client.send_get("get_runs/#{projectId}&suite_id=#{suitId}&section_id=#{sectionId}")
      end

    
      def getPayloadsFromSteps(steps)
         payloads = Array.new
         steps.each do |cases|
            if cases.has_value?("Payload") then
               payloads.push(cases)
            end
         end
         return payloads
      end
	end  
end
#testRailUtility = EnziTestRailUtility::TestRailUtility.new('team-qa@enzigma.com','7O^dv0mi$IZHf4Cn')
#puts testRailUtility.getProjectByName("Cellaaaaaa")
#puts "Suites-->"
#suitJson = testRailUtility.getSuites(4)
#puts suitJson[0]

#suitId = testRailUtility.getSuitByName(4,"Rest API Tester")
#puts suitId
#puts "Run-->"
#run = testRailUtility.addRun("RestAPITestContractEventTest",4,26)
#puts run["id"]
#puts "Adding result-->"
#puts testRailUtility.postResult(451,"comment",1,run["id"])
#puts testRailUtility.getPayloadsFromSteps(testRailUtility.getCase(363)['custom_steps_separated'])
#payload = testRailUtility.getCase(366)['custom_steps_separated'][0]['expected']
#puts testRailUtility.getCase(320)
#puts testRailUtility.getRuns("26","69","4")
#puts JSON.parse(payload)
#response = testRailUtility.getRuns("26","68","4")
#puts "res :: #{response}"

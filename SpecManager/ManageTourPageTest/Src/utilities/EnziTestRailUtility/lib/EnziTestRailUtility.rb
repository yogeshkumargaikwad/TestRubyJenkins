require 'yaml'
require_relative('testRail/api_client')
module EnziTestRailUtility
	class TestRailUtility

		def initialize(username,password)
			@client = TestRail::APIClient.new('https://enzigma.testrail.io/')
			@client.user = username
			@client.password = password
		end

		def getCase(caseId)
			url = "get_case/#{caseId}"
			return @client.send_get(url)
		end

		def getCases(projectId, suiteId, sectionId)
			if !sectionId.nil? && !suiteId.nil? && !projectId.nil? then
				return @client.send_get("get_cases/#{projectId}&suite_id=#{suiteId}&section_id=#{sectionId}")
			end
			if !sectionId.nil? then
				return @client.send_get("get_cases/#{projectId}&section_id=#{sectionId}")
			else
				#Getting cases from suit id only if project is operating in single suit mode otherwise required
				if getSuites(projectId).size == 1 && !suiteId.nil? then
					return @client.send_get("get_cases/#{projectId}&suite_id=#{suiteId}")
					#Getting cases from project id is valid iff project is operating in single suit mode
				else
					if getSuites(projectId).size == 1 && !projectId.nil? then
						return @client.send_get("get_cases/#{projectId}")
					end
				end
			end
		end

		def getSuite(suiteId)
			url = "get_suite/#{suiteId}"
			return @client.send_get(url)
		end

		def getSuites(projectId)
			url = "get_suites/#{projectId}"
			return @client.send_get(url)
		end

		def getProject(projectId)
			url = "get_project/#{projectId}"
			return @client.send_get(url)
		end

		def getProjects()
			return @client.send_get('get_projects')
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

		def getCaseFields
			@client.send_get("get_case_fields")
		end

		def getSpecLocations(caseId,sectionId,suitId,planId,projectId)
			specLocations = Array.new
			if !caseId.nil? then
				specLocations.push(getCase(caseId)['custom_spec_location'])
			else
				if !sectionId.nil? && getSuites(projectId).size == 1  then
					specLocations.push(getCases(projectId, suitId, sectionId)[0]['custom_spec_location'])
				else
					#Getting cases from suit id only if project is operating in single suit mode otherwise required
					if !suitId.nil? then
            puts "getting specs for suit :: #{suitId}"
						getSections(suitId,projectId).each do |section|
							specLocations.push(getCases(projectId, suitId, section['id'])[0]['custom_spec_location'])
						end
					else
						if !planId.nil? then
							plan = getPlan(planId)
							plan['entries'].each do |entry|
								suit = entry['suite_id']
								getSections(suit,projectId).each do |section|
									specLocations.push(getCases(projectId, suit, section['id'])[0]['custom_spec_location'])
								end
							end
						else
							if !projectId.nil? then
								puts "getting specs from project id"
                specLocation = nil
								getSuites(projectId).each do |suit|
									getSections(suit['id'],projectId).each do |section|
                    getCases(projectId, suit['id'], section['id']).each do |testCase|
                      if testCase.key?('custom_spec_location') then
                        specLocation = testCase.fetch('custom_spec_location')
                        break;
                      end
                    end
                    if !specLocation.nil? then
										  specLocations.push(specLocation)
                    end
									end
								end
							end
						end
					end
				end
			end
			puts "spec to be run are :: #{specLocations.uniq}"
			return specLocations.uniq
		end

		def getPlan(planId)
			@client.send_get("get_plan/#{planId}")
		end

		def getTests(runId)
			@client.send_get("get_tests/#{runId}")
		end

		def getTest(testId)
			@client.send_get("get_test/#{testId}")
		end

		def getSections(suitId, projectId)
			@client.send_get("get_sections/#{projectId}&suite_id=#{suitId}")
		end

		def getSection(sectionId)
			@client.send_get("get_section/#{sectionId}")
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
			@client.send_post("add_run/#{projectId}", {
					"suite_id": "#{suiteId}",
					"name": "#{test_run_name}- #{Time.now.asctime}",
					"include_all": true
			})
		end
	end
end
#testRailUtility = EnziTestRailUtility::TestRailUtility.new("team-qa@enzigma.com","7O^dv0mi$IZHf4Cn")
#puts testRailUtility.getSuites(4)
#puts testRailUtility.getSection(22)['suite_id']
#puts testRailUtility.getSpecLoaction(nil,69,nil,nil,4)
#testRailUtility = EnziTestRailUtility::TestRailUtility.new project_id suite_id
#puts testRailUtility.addRun("testing",4,26)['id']
#puts testRailUtility.getPayloadsFromSteps(testRailUtility.getCase(363)['custom_steps_separated'])
#payload = testRailUtility.getCase(366)['custom_steps_separated'][0]['expected']
#puts testRailUtility.getCase(320)
#puts testRailUtility.getRuns("26","69","4")
#puts JSON.parse(payload)
#response = testRailUtility.getRuns("26","68","4")
#puts "res :: #{response}"
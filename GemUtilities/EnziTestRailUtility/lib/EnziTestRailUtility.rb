require 'yaml'
require_relative('testrail/api_client')
module EnziTestRailUtility
	class TestRailUtility

		def initialize(username,password)
			@client = TestRail::APIClient.new('https://enzigma.testrail.io/')
			@client.user = username
			@client.password = password
		end
		def getSuites(projectId)
			url = "get_suites/#{projectId}"
			return @client.send_get(url)
		end
		def addRuns(projectId)
			getSuites(projectId).each do |suite|
				addRun(getProject(projectId)['name'],projectId,suite['id'],nil)
			end
		end
		def addRun(test_run_name,projectId,suiteId,caseIDs)
			if !caseIDs.nil? && caseIDs.size > 0 then
				data = {
						"suite_id": suiteId,
						"name": "#{test_run_name}- #{Time.now.asctime}",
						"include_all": false,
						"case_ids": caseIDs
				}else
					 data = {"suite_id": suiteId,"name": "#{test_run_name}- #{Time.now.asctime}","include_all": true}
			end
			@client.send_post("add_run/#{projectId}", data)
    end
    def deleteRun(runId)
      @client.send_get("delete_run/#{runId}")
    end
		def getSpecLocations(caseId,sectionId,suitId,planId,projectId)
			specLocations = Array.new
			if !caseId.nil? then
				testCase = getCase(caseId)
				specLocations.push(Hash["path"=>testCase.fetch('custom_spec_location'),"isBrowserDependent"=>testCase.fetch('custom_is_browser_dependent')])
			else
				if !sectionId.nil? && getSuites(projectId).size == 1  then
					getCases(projectId, nil, sectionId).each do |testCase|
						if testCase.key?('custom_spec_location') && !testCase.fetch('custom_spec_location').nil? then
							specLocations.push(Hash["path"=>testCase.fetch('custom_spec_location'),"isBrowserDependent"=>testCase.fetch('custom_is_browser_dependent')])
							break;
						end
					end
				else
					#Getting cases from suit id only if project is operating in single suit mode otherwise required
					if !suitId.nil? then
						if !sectionId.nil? then
							getCases(projectId, suitId, sectionId).each do |testCase|
								if testCase.key?('custom_spec_location') && !testCase.fetch('custom_spec_location').nil? then
									specLocations.push(Hash["path"=>testCase.fetch('custom_spec_location'),"isBrowserDependent"=>testCase.fetch('custom_is_browser_dependent')])
									break;
								end
							end
						else
							getSections(suitId,projectId).each do |section|
								getCases(projectId, suitId, section['id']).each do |testCase|
									if testCase.key?('custom_spec_location') && !testCase.fetch('custom_spec_location').nil? then
										specLocations.push(Hash["path"=>testCase.fetch('custom_spec_location'),"isBrowserDependent"=>testCase.fetch('custom_is_browser_dependent')])
										break;
									end
								end
							end
						end
					else
						if !planId.nil? then
							plan = getPlan(planId)
							plan['entries'].each do |entry|
								suit = entry['suite_id']
								getSections(suit,projectId).each do |section|
									getCases(projectId, suit, section['id']).each do |testCase|
										if testCase.key?('custom_spec_location') && !testCase.fetch('custom_spec_location').nil? then
											specLocations.push(Hash["path"=>testCase.fetch('custom_spec_location'),"isBrowserDependent"=>testCase.fetch('custom_is_browser_dependent')])
											break;
										end
									end
								end
							end
            else
              if !projectId.nil? then
								specLocation = nil
								getSuites(projectId).each do |suit|
=begin
                  if sections.size > 0 then
                    arrCaseIds = Array.new
                    sections.each do |section|
                      getCases(projectId,suit['id'],section['id']).each do |testCase|
                        if testCase.key?('custom_spec_location') && !testCase.fetch('custom_spec_location').nil? then
                          arrCaseIds.push(testCase['id'])
                        end
                      end
                    end
                    if arrCaseIds.size > 0 then
                      runId = addRun(suit['name'],projectId,suit['id'],arrCaseIds)['id'].to_s
                    end
end
=end

								getSections(suit['id'],projectId).each do |section|
                        getCases(projectId, suit['id'], section['id']).each do |testCase|
											if testCase.key?('custom_spec_location') && !testCase.fetch('custom_spec_location').nil? then
												specLocations.push(Hash["path"=>testCase.fetch('custom_spec_location'),"isBrowserDependent"=>testCase.fetch('custom_is_browser_dependent')])
												break;
											end
										end
                  end
								end
							end
						end
					end
				end
				return specLocations.uniq
			end
		end
		#StatusId ::
		#1  Passed
		#2  Blocked
		#3  Untested (not allowed when adding a result)
		#4  Retest
		#5  Failed
		def postResult(caseId,comment,statusId,testRunId)
			url = "add_result_for_case/#{testRunId}/#{caseId}"
			@client.send_post(url, { :status_id => statusId, :comment => "#{comment}" })
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

		def getProject(projectId)
			url = "get_project/#{projectId}"
			return @client.send_get(url)
		end

		def getProjects()
			return @client.send_get('get_projects')
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

		def getRun(runId)
			@client.send_get("get_run/#{runId}")
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

		def getSections(suitId, projectId)
			@client.send_get("get_sections/#{projectId}&suite_id=#{suitId}")
		end

		def getSection(sectionId)
			@client.send_get("get_section/#{sectionId}")
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
	end
end

#testRailUtility = EnziTestRailUtility::TestRailUtility.new("team-qa@enzigma.com","7O^dv0mi$IZHf4Cn")
#ENV['RUN_ID'] =  testRailUtility.addRun(testRailUtility.getSuite(26)['name'],4,26,nil)['id'].to_s
#puts testRailUtility.getRun(625)['suite_id']
#puts testRailUtility.getSpecLoaction(nil,69,nil,nil,4)
#testRailUtility = EnziTestRailUtility::TestRailUtility.new project_id suite_id
#puts testRailUtility.addRun("testing",4,26)['id']
#puts testRailUtility.getPayloadsFromSteps(testRailUtility.getCase(363)['custom_steps_separated'])
#payload = testRailUtility.getCase(366)['custom_steps_separated'][0]['expected']
#puts testRailUtility.getCase(1012).inspect
#puts testRailUtility.getRuns("26","69","4")
#puts JSON.parse(payload)
#response = testRailUtility.getRuns("26","68","4")
#puts "res :: #{response}"

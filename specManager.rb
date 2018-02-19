#Created By : Monika Pingale
#Created Date : 31/01/2018
#Modified date :
require 'yaml'
require 'rspec'
require 'json'
require_relative File.expand_path("GemUtilities/EnziTestRailUtility/lib/EnziTestRailUtility.rb")
specMap = Hash.new
config = YAML.load_file('credentials.yaml')
testRailUtility = EnziTestRailUtility::TestRailUtility.new(config['TestRail']['username'],config['TestRail']['password'])
if ARGV.size == 1 &&  !ENV['PROJECT_ID'].nil? then
  ARGV = ["project:#{ENV['PROJECT_ID']}", "suit:#{ENV['SUIT_ID']}" , "section:#{ENV['SECTION_ID']}" , "browser:#{ENV['BROWSERS']}"]
end
if !ARGV.empty? then
  ARGV.each do |input|
    containerInfo = input.split(":")
    if specMap.key?(containerInfo[0]) && containerInfo.size > 1 then
      specMap[containerInfo[0]] << containerInfo[1].split(",")
    else
      if containerInfo.size > 1 then
        specMap[containerInfo[0]] = containerInfo[1].split(",")
      end
    end
  end
  specs = Array.new
  if !specMap.empty? && !specMap.values.empty? then
    if specMap.key?('case') then
      RSpec.configuration.filter_run_including specMap.fetch('case')[0].to_sym
      if specMap.key?('case') && specMap.key?('section') && specMap.key?('suit') && specMap.key?('project') then
        specMap.fetch('case').each do |caseId|
          specs.concat(testRailUtility.getSpecLocations(caseId,specMap.fetch('case'),specMap.fetch('suit'),nil,specMap.fetch('project')))
        end
      else
        specs.concat(testRailUtility.getSpecLocations(caseId,specMap.fetch('case'),nil,nil,nil))
      end
    end
    if !specMap.key?('case') && specMap.key?('section') then
      if specMap.key?('suit') && specMap.key?('project') then
        specMap.fetch('section').each do |sectionId|
          specs.concat(testRailUtility.getSpecLocations(nil,sectionId,specMap.fetch('suit')[0],nil,specMap.fetch('project')[0]))
        end
      else
        specMap.fetch('section').each do |sectionId|
          suitId  = testRailUtility.getSection(sectionId)['suite_id']
          specs.concat(testRailUtility.getSpecLocations(nil,sectionId,suitId,nil,testRailUtility.getSuite(suitId)['project_id']))
        end
      end
    end
    if !specMap.key?('case') &&!(specMap.key?('section')) && specMap.key?('suit') then
      if specMap.key?('project') then
        specMap.fetch('suit').each do |suitId|
          arrCaseIds = Array.new
          suitInfo = testRailUtility.getSuite(suitId)
          testRailUtility.getSections(suitInfo['id'],suitInfo['project_id']).each do |section|
            testRailUtility.getCases(suitInfo['project_id'],suitId,section['id']).each do |testCase|
              if testCase.key?('custom_spec_location') && !testCase.fetch('custom_spec_location').nil? then
                arrCaseIds.push(testCase['id'])
              end
            end
          end
          if arrCaseIds.size > 0 then
            ENV['RUN_ID'] = testRailUtility.addRun(suitInfo['name'],specMap.fetch('project')[0],suitId,arrCaseIds)['id'].to_s
          end
          specs.concat(testRailUtility.getSpecLocations(nil,nil,suitId,nil,specMap.fetch('project')[0]))
        end
      else
        specMap.fetch('suit').each do |suitId|
          arrCaseIds = Array.new
          suitInfo = testRailUtility.getSuite(suitId)
          testRailUtility.getSections(suitInfo['id'],suitInfo['project_id']).each do |section|
            testRailUtility.getCases(suitInfo['project_id'],suitId,section['id']).each do |testCase|
              if testCase.key?('custom_spec_location') && !testCase.fetch('custom_spec_location').nil? then
                arrCaseIds.push(testCase['id'])
              end
            end
          end
          if arrCaseIds.size > 0 then
            ENV['RUN_ID'] = testRailUtility.addRun(suitInfo['name'],specMap.fetch('project')[0],suitId,arrCaseIds)['id'].to_s
          end
          specs.concat(testRailUtility.getSpecLocations(nil,nil,suitId,nil,suitInfo['project_id']))
        end
      end
    end
    if specMap.key?('plan') then
      specMap.fetch('plan').each do |planId|
        specs.concat(testRailUtility.getSpecLocations(nil,nil,nil,planId,nil))
      end
    end
    if  !(specMap.key?('suit') || specMap.key?('section')) && specMap.key?('project') then
      specMap.fetch('project').each do |projectId|
        specs.concat(testRailUtility.getSpecLocations(nil,nil,nil,nil,projectId))
      end
    end
  end
  if !specs.empty? then
    #RSpec::Core::Formatters::BaseTextFormatter "--pattern **/*_spec.rb --format ParallelTests::RSpec::FailuresLogger --out rspec.txt
    specs.uniq.each do |spec|
      #Run spec in multiple browsers
      if !spec.nil? then
        puts "spec to run :: #{spec}"
        if !ENV['PROJECT_ID'].nil? && ENV['SUIT_ID'].nil? && ENV['SECTION_ID'].nil? then
          ENV['RUN_ID'] = spec['runId']
          puts "Run Id is :: #{ ENV['RUN_ID']}"
        end
        if spec['isBrowserDependent'] then
          arrBrowsers =Array.new
          if !specMap.key?('browser') || specMap.fetch('browser').nil? then
            specMapping = YAML.load_file("specMapping.json")
            arrBrowsers.push(specMapping['BrowserCapabilities']['Name'])
          else
            arrBrowsers = specMap.fetch('browser')[0].split(" ")
          end
          arrBrowsers.each do |browser|
            ENV['BROWSER'] = browser
            puts [spec['path']]
            RSpec::Core::Runner.run([spec['path']], $stderr, $stdout)
=begin
            if !RSpec.configuration.reporter.failed_examples.empty? then
              out_file = File.new("exceptions.txt", "w")
              out_file.puts(RSpec.configuration.reporter.failed_examples.to_s)
              out_file.close
              mailUtility = MailUtility.new("monika.pingale@enzigma.in","arya@1994")
              mailUtility.sendMail('monika.pingale@enzigma.in',"exceptions.txt")
            else
              puts "Successfully tested"
            end
=end
            RSpec.clear_examples
            RSpec.reset
          end
        else
          puts [spec['path']]
          RSpec::Core::Runner.run([spec['path']], $stderr, $stdout)
          #puts "Failed examples are :: #{RSpec.configuration.reporter.failed_examples}"
=begin
            if !RSpec.configuration.reporter.failed_examples.empty? then
              out_file = File.new("exceptions.txt", "w")
              out_file.puts(RSpec.configuration.reporter.failed_examples.to_s)
              out_file.close
              mailUtility = MailUtility.new("monika.pingale@enzigma.in","arya@1994")
              mailUtility.sendMail('monika.pingale@enzigma.in',"exceptions.txt")
            else
              puts "Successfully tested"
            end
=end
            RSpec.clear_examples
            RSpec.reset
        end
      end
    end
  end
end
=begin
if !ARGV.empty? then
  specMapping = JSON.parse(File.read("specMapping.json"))

  ARGV.each do |input|
    type = input.split(":")
    #Select spec to run by given input
    specMapping[''+type[0]].each do |inputType|
      type[1].split(",").each do |id|
        if inputType.has_key?(id) then
          inputType.fetch(id).each do |spec|
            specs.push(spec)
          end
        end
      end
    end
  end
  if !specs.empty? then
    specs.each do |spec|
      #Run spec in multiple browsers
      puts spec
      if spec['isBrowserDependent'] then
        specMapping['BrowserCapabilities'].each do |browser|
          puts browser
          ENV['BROWSER'] = browser['Name']
          RSpec::Core::Runner.run([spec['path']], $stderr, $stdout)
          RSpec.clear_examples
      end
      else
        RSpec::Core::Runner.run([spec['path']], $stderr, $stdout)
      end
    end
  end
end
=end


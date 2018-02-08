#Created By : Monika Pingale
#Created Date : 31/01/2018
#Modified date :
require 'yaml'
require 'rspec'
require 'json'
require_relative "CustomRESTAPITest/Src/utilities/EnziTestRailUtility/lib/EnziTestRailUtility.rb"
puts "Input is :: #{ARGV}"
specMap = Hash.new
config = YAML.load_file('CustomRESTAPITest/Src/testData/credentials.yaml')
testRailUtility = EnziTestRailUtility::TestRailUtility.new(config['TestRail']['username'],config['TestRail']['password'])
ARGV.each do |input|
  containerInfo = input.split(":")
  if specMap.key?(containerInfo[0]) then
    specMap[containerInfo[0]] << containerInfo[1].split(",")
  else
    specMap[containerInfo[0]] = containerInfo[1].split(",")
  end
end
specs = Array.new
puts "Spec Map :: #{specMap}"
if !specMap.empty? then
  if specMap.key?('case') then
    if specMap.key?('case') && specMap.key?('section') && specMap.key?('suit') && specMap.key?('project') then
      specMap.fetch('case').each do |caseId|
        specs.concat(testRailUtility.getSpecLocations(caseId,specMap.fetch('case'),specMap.fetch('suit'),nil,specMap.fetch('project')))
      end
    else
      specs.concat(testRailUtility.getSpecLocations(caseId,specMap.fetch('case'),nil,nil,nil))
    end
  end
  if specMap.key?('section') then
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
  if !(specMap.key?('section')) && specMap.key?('suit') then
    if specMap.key?('project') then
      specMap.fetch('suit').each do |suitId|
        specs.concat(testRailUtility.getSpecLocations(nil,nil,suitId,nil,specMap.fetch('project')[0]))
      end
    else
      specMap.fetch('suit').each do |suitId|
        specs.concat(testRailUtility.getSpecLocations(nil,nil,suitId,nil,testRailUtility.getSuite(suitId)['project_id']))
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
  if !specs.empty? then
    specMapping = JSON.parse(File.read("specMapping.json"))
    specs.each do |spec|
      #Run spec in multiple browsers
      if !spec.nil? then
        puts "spec to run :: #{spec}"
        puts "spec path :: #{spec['path']}"
        puts "browser :: #{spec['isBrowserDependent']}"
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


#Created By : Monika Pingale
#Created Date : 31/01/2018
#Modified date :
require 'yaml'
require 'rspec'
require 'json'
require "selenium-webdriver"
require 'enziUIUtility'
require_relative File.expand_path(Dir.pwd+"/GemUtilities/EnziTestRailUtility/lib/EnziTestRailUtility.rb")
specMap = Hash.new
mapSuitRunId = Hash.new
config = YAML.load_file('credentials.yaml')
testRailUtility = EnziTestRailUtility::TestRailUtility.new(config['TestRail']['username'],config['TestRail']['password'])
if ARGV.size == 1 &&  !ENV['PROJECT_ID'].nil? then
  ARGV = ["project:#{ENV['PROJECT_ID']}", "suit:#{ENV['SUIT_ID']}" , "section:#{ENV['SECTION_ID']}" , "browser:#{ENV['BROWSERS']}" , "case:#{ENV['CASE_ID']}"]
end
if !ARGV.empty? then
  ARGV.each do |input|
    containerInfo = input.split(":")
    if specMap.key?(containerInfo[0]) && containerInfo.size > 1 then
      specMap[containerInfo[0]] << containerInfo[1].split(",").uniq
    else
      if containerInfo.size > 1 then
        specMap[containerInfo[0]] = containerInfo[1].split(",").uniq
      end
    end
  end
  specs = Array.new
  if !specMap.empty? && !specMap.values.empty? then
    if specMap.key?('case') && specMap.fetch('case').size > 0 then
      RSpec.configuration.filter_runs_including(specMap.fetch('case'))
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
          specs.concat(testRailUtility.getSpecLocations(nil,nil,suitId,nil,specMap.fetch('project')[0]))
        end
      else
        specMap.fetch('suit').each do |suitId|
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
  
  if !ENV['PROJECT_ID'].nil? && ENV['SUIT_ID'].nil? && ENV['SECTION_ID'].nil? then
    ENV['RUN_ID'].split(",").each do |runId|
      mapSuitRunId[testRailUtility.getSpecLocations(nil,nil,testRailUtility.getRun(runId)['suite_id'],nil,ENV['PROJECT_ID'])[0]['path']] = runId
    end
  end
  if !specs.empty? then
    specs.uniq.each do |spec|
      #Run spec in multiple browsers
      if !spec.nil? then
        if !ENV['PROJECT_ID'].nil? && ENV['SUIT_ID'].nil? && ENV['SECTION_ID'].nil? then
          ENV['RUN_ID'] = mapSuitRunId[spec['path']]
        end
        if spec['isBrowserDependent'] then
          specMap.fetch('browser')[0].split(" ").each do |browser|
            #ENV['BROWSER'] = browser
            ARGV[0] = Selenium::WebDriver.for browser.to_sym
            ARGV[0].get "https://test.salesforce.com/login.jsp?pw=#{config['Staging']['password']}&un=#{config['Staging']['username']}"
            EnziUIUtility.wait(ARGV[0], :id, 'phSearchInput', YAML.load_file('timeSettings.yaml')['Wait']['Environment']['Classic']['Max'])
            ARGV[0].get "#{ARGV[0].current_url().split('/home')[0]}/005?isUserEntityOverride=1&retURL=/ui/setup/Setup?setupid=Users&setupid=ManageUsers"
            EnziUIUtility.wait(ARGV[0], :name, 'new', YAML.load_file('timeSettings.yaml')['Wait']['Environment']['Classic']['Min'])
            YAML.load_file(Dir.pwd+'/UserSettings.yaml')['profile'].each do |profile|
              EnziUIUtility.loginForUser(ARGV[0],profile)
              EnziUIUtility.switchToWindow(ARGV[0],ARGV[0].current_url())
              puts "Successfully Logged In with #{profile} "
              ::RSpec::Core::Runner.run([spec['path']], $stderr, $stdout)
              RSpec.clear_examples
            endss
          end
        else
          ::RSpec::Core::Runner.run([spec['path']], $stderr, $stdout)
          RSpec.clear_examples
        end
      end
    end
  end
end


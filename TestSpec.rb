require 'rspec'
class Test
  def initialize
    puts "#{ENV['BROWSER']}/geckodriver.exe"
    puts 'Hello Enzigma!'
  end
end
describe 'Test behaviour' do
  it 'should display message' do
    puts 'In display message test case'
    objActualTest = Test.new
    strExpectedMsg = "Hello Enzigma!"
    strExpectedMsg.eql?(objActualTest)
  end
end

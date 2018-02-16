require 'rspec'
require 'rspec/repeat'
RSpec.configure do |config|
    config.include RSpec::Repeat
    config.around :each do
      repeat example, 3.times, verbose: true
    end
end
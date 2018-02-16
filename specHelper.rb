require 'rspec'
  # Retrieve a list of formatters
  formatters = RSpec.configuration.formatters
  config = RSpec.configuration
  config.add_formatter(:json)
  config.add_formatter(:documentation)
  #formater = RSpec::Core::Formatters::JsonFormatter.new(config.instance_variable_get(:@output_stream))
  formatter = RSpec::Core::Formatters::JsonFormatter.new(config.instance_variable_get(:@output_stream))
  reporter  = RSpec::Core::Reporter.new(config)
  # create reporter with json formatter
  #reporter =  RSpec::Core::Reporter.new(config)
  # set reporter for rspec configuration
  config.instance_variable_set(:@reporter, reporter)
  loader = config.send(:formatter_loader)
  notifications = loader.send(:notifications_for, RSpec::Core::Formatters::JsonFormatter)
  reporter.register_listener(formatter, *notifications)



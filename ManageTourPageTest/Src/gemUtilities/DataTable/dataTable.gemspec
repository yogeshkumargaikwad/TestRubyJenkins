Gem::Specification.new do |s|
  s.name        = 'dataTable'
  s.version     = '0.0.0'
  s.date        = '2017-10-17'
  s.summary     = "Data table functionality check gem"
  s.description = "This gem is use to check functionality of data table"
  s.authors     = ["ROR"]
  s.email       = 'ROR@enzigma.in'
  s.files       = ["lib/dataTable.rb"]
  s.homepage    = 'http://localhost'
  s.license       = 'MIT'
  s.add_runtime_dependency  'rspec',  '~> 3.6', '>= 3.6.0'
  s.add_runtime_dependency  'selenium-webdriver', '~> 3.4', '>= 3.4.4'
end
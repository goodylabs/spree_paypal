# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_paypal'
  s.version     = '2.0.3'
  s.summary     = 'Spree extension for using the Paypal payment service'
  s.description = 'This extension adds credit card payments via the payment provider paypal (with confirmation step) to spree'
  s.required_ruby_version = '>= 1.9.3'

  s.author    = 'goodylabs sp. z o.o.'
  s.email     = 'goodies@goodylabs.com'
  s.homepage  = 'http://www.goodylabs.com'

  #s.files       = `git ls-files`.split("\n")
  #s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 2.0.3'
  s.add_dependency 'activemerchant', '~> 1.32'

  s.add_development_dependency 'capybara', '~> 1.1.2'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'factory_girl', '~> 2.6.4'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails',  '~> 2.9'
  s.add_development_dependency 'sass-rails'
  s.add_development_dependency 'sqlite3'
end

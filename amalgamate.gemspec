$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "amalgamate/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "amalgamate"
  s.version     = Amalgamate::VERSION
  s.authors     = ["Daniel Reedy"]
  s.email       = ["danreedy@gmail.com"]
  s.homepage    = "http://reedy.in"
  s.summary     = "Amalgamate allows combining multiple ActiveRecord objects"
  s.description = "Amalgamate allows you to combine multiple ActiveRecord objects, updating assocations, finding duplicates, and maintaining cleaner code."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 3.2.11"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "capybara"
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "faker"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "rb-fsevent"
  s.add_development_dependency "guard-spork"
end

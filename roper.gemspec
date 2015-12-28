$:.push File.expand_path("../lib", __FILE__)

require "roper/version"

Gem::Specification.new do |s|
  s.name        = "roper"
  s.version     = Roper::VERSION
  s.authors     = ["Brian Ploetz"]
  s.email       = ["bploetz@gmail.com"]
  s.homepage    = "https://www.github.com/bploetz/roper"
  s.summary     = "Rails OAuth2 Provider"
  s.description = "Rails OAuth2 Provider"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", ">= 4"
  s.add_dependency "uuidtools", "~> 2.1"
  s.add_dependency "bcrypt"
  s.add_dependency "interactor", "~> 3.0"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "mongoid", "~> 5"
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'simplecov'
end

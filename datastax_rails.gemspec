$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "datastax_rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "datastax_rails"
  s.version     = DatastaxRails::VERSION
  s.authors     = ["Jason M. Kusar"]
  s.email       = ["jason@kusar.net"]
  s.homepage    = "https://github.com/jasonmk/datastax_rails"
  s.summary     = "A Ruby-on-Rails interface to Datastax Enterprise"
  s.description = "A Ruby-on-Rails interface to Datastax Enterprise. Intended for use with the DSE search nodes."
  s.license     = 'MIT'

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.1", ">= 4.0.0"
  s.add_dependency "cql-rb", "~> 1.2", ">= 1.2.1"
  s.add_dependency "rsolr", "~> 1.0", ">= 1.0.9"
  s.add_dependency "rsolr-client-cert", "~> 0.5", ">= 0.5.2"
  
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "capybara"
end

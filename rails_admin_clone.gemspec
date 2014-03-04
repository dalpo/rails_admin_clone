$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rails_admin_clone/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "rails_admin_clone"
  s.version     = RailsAdminClone::VERSION
  s.authors     = ["Andrea Dal Ponte"]
  s.email       = ["info@andreadalponte.com"]
  s.homepage    = "https://github.com/dalpo/rails_admin_clone"
  s.summary     = "Rails Admin plugin to clone records"
  s.description = "Rails Admin custom action to clone records"
  s.license     = 'MIT'

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency 'rails', '>= 3.2'
  s.add_dependency 'rails_admin', '>= 0.4'
end


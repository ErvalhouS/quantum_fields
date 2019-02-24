$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "quantum_fields/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "quantum_fields"
  spec.version     = QuantumFields::VERSION
  spec.authors     = ["Fernando Bellincanta"]
  spec.email       = ["ervalhous@hotmail.com"]
  spec.homepage    = "https://github.com/ErvalhouS/quantum_fields"
  spec.summary     = "Give noSQL powers to your SQL database"
  spec.description = "QuantumFields is a gem to extend your Rails model's making them able to use virtual fields from a JSON column or a Text column serialized as a Hash. This means that you can use fields that were not explicitly declared in your schema as if they were."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "> 5"

  spec.add_development_dependency "rspec"
  spec.add_development_dependency "sqlite3", "~> 1.3.6"
  spec.add_development_dependency "pg"
  spec.add_development_dependency "mysql2"
end

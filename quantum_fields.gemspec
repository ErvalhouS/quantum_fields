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

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "> 5"

  spec.add_development_dependency "rspec"
  spec.add_development_dependency "sqlite3", "~> 1.3.6"
  spec.add_development_dependency "pg"
  spec.add_development_dependency "mysql2"
end

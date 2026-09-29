# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "arangodb-odm"
  s.version = "0.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Oliver Kiessler"]
  s.description = "ArangoDB ODM for Ruby"
  s.email = "kiessler@inceedo.com"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "lib/arangodb-odm.rb",
    "lib/collections.rb",
    "lib/indices.rb",
    "lib/queries.rb",
    "test/another_example_document.rb",
    "test/example_document.rb",
    "test/example_edge.rb",
    "test/helper.rb",
    "test/test_arangodb-odm.rb",
    "test/test_collections.rb",
    "test/test_indices.rb",
    "test/test_queries.rb"
  ]
  s.homepage = "http://github.com/okiess/arangodb-odm"
  s.licenses = ["MIT"]
  s.summary = "ArangoDB Object Document Mapper"

  s.add_runtime_dependency "httparty", ">= 0.21.0"
  s.add_runtime_dependency "json"

  s.add_development_dependency "shoulda"
  s.add_development_dependency "bundler", ">= 2.0"
  s.add_development_dependency "rake", ">= 12.3.3"
  s.add_development_dependency "git", ">= 1.11.0"
  s.add_development_dependency "test-unit", "~> 3.7"
end

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'arangodb-odm'
require 'example_document.rb'
require 'another_example_document.rb'

# Set your ArangoDB host...
ArangoDb::Transport.base_uri 'http://localhost:8529'

# Initial setup
ExampleDocument.create_collection # only needed to be able to create indices on the initial test run
ExampleDocument.ensure_indices
# AnotherExampleDocument.create_collection

class Test::Unit::TestCase
end

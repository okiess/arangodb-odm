# arangodb-odm

## Installation

  gem install arangodb-odm

## Example Code

### Example with dynamic attributes

	class ExampleDocument < ArangoDb::Base
  		collection :examples
	end

### Example with predefined attributes

	class AnotherExampleDocument < ArangoDb::Base
  		collection :more_examples
  		db_attrs :foo, :bar # only these attributes will be saved
	end

## Usage

	doc = ExampleDocument.new
	doc.foo = "bar"
	_id = doc.save

	doc.foo = "bar2"
	_rev = doc.save

	success = doc.destroy
 
	doc = ExampleDocument.find(_id)
	doc2 = ExampleDocument.create("foo" => "bar")

	all_document_handles = ExampleDocument.keys

## Copyright

Copyright (c) 2012 Oliver Kiessler. See LICENSE.txt for
further details.

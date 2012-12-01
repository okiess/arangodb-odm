# arangodb-odm

## Installation

    gem install arangodb-odm

## Configuration

    ArangoDb::Transport.base_uri 'http://localhost:8529'

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
	
## Simple Queries

    docs = ExampleDocument.all(limit => :10, :skip => 10)

## Callbacks

    class ExampleDocument < ArangoDb::Base
      collection :examples

      before_create :add_something
      after_create :do_something_else

      before_destroy :method1
      after_destroy :method2

      before_save :change_something
      after_save :change_something_else

      # Called before create/save
      # must return true if the document is valid
      def validate
        not self.foo.nil?
      end

      def add_something
        self.something = "other"
      end

      def do_something_else; end

      def method1
        puts self._id # not nil
      end

      def method2
        puts self._id # is nil
      end

      def change_something
        self.foo = 'bar2'
      end

      def change_something_else; end
    end

## Copyright

Copyright (c) 2012 Oliver Kiessler. See LICENSE.txt for
further details.

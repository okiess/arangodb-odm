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

### CRUD

	doc = ExampleDocument.new
	doc.foo = "bar"
	_id = doc.save

	doc.foo = "bar2"
	_rev = doc.save

	success = doc.destroy
 
	doc = ExampleDocument.find(_id)
	doc2 = ExampleDocument.create("foo" => "bar")

	all_document_handles = ExampleDocument.keys
	
### Simple Queries

#### All

    ExampleDocument.all
    ExampleDocument.skip(1).limit(2).all
    
#### All by example
    
    ExampleDocument.where('foo' => 'bar').all
    ExampleDocument.where('foo' => 'bar').skip(10).limit(10).all
    ExampleDocument.where('foo' => 'bar').where('a' => 'b').skip(10).limit(10).all

#### First by example
    
    ExampleDocument.where('foo' => 'bar', 'a' => 'b').first
    
#### Range

    # Make sure you've setup a skip-list index on the attribute
    ExampleDocument.attribute('test').left(0).right(100).all
    ExampleDocument.attribute('test').left(0).right(100).closed(true).skip(10).limit(10).all

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
    
## Indices

### Skip List Index Definition

    class ExampleDocument < ArangoDb::Base
      collection :examples
      skiplist :test, :something_else
    end

### Creating indices

    # Creates all indices defined in the document. Run it once when you setup your document model...
    ExampleDocument.ensure_indices

## Copyright

Copyright (c) 2012 Oliver Kiessler. See LICENSE.txt for
further details.

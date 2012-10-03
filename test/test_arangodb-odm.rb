require 'helper'

class ExampleDocument < ArangoDb::Base
  collection :examples
  before_create :add_something
  after_create :do_something_else

  def validate
    not self.foo.nil?
  end
  
  def add_something
    self.something = "other"
  end
  
  def do_something_else; end
end

# Example with predefined attributes
class AnotherExampleDocument < ArangoDb::Base
  collection :more_examples
  db_attrs :foo, :bar
end

class TestArangoDbRb < Test::Unit::TestCase
  should "class should have a collection" do
    assert_equal ExampleDocument.collection, 'examples'
    assert_equal AnotherExampleDocument.collection, 'more_examples'
  end

  should "create a new document" do
    doc = ExampleDocument.new
    doc.foo = "bar"
    doc.test = 1
    doc.list = [1, 2, 3]

    assert_nil doc._id
    assert_nil doc._rev
    assert_nil doc.location

    _id = doc.save
    assert_not_nil _id
    assert_not_nil doc._id
    assert_not_nil doc._rev
    assert_not_nil doc.location

    doc = ExampleDocument.find(_id)
    assert_equal doc._id, _id
    assert_equal doc.foo, "bar"
    assert_equal doc.test, 1
    assert_equal doc.list, [1, 2, 3]

    doc2 = AnotherExampleDocument.new
    doc2.foo = 'bar'
    doc2.bar = 'foo'
    doc2.foo2 = 'bar2' # won't be saved => not in predefined db_attrs
    _id = doc2.save
    assert_not_nil _id
    assert_not_nil doc2._id
    assert_not_nil doc2._rev
    assert_not_nil doc2.location

    doc3 = AnotherExampleDocument.find(_id)
    assert_nil doc3.foo2
    assert_equal doc3.foo, 'bar'
    assert_equal doc3.bar, 'foo'
  end

  should "create a document on the create class method" do
    doc = ExampleDocument.create(:foo => "bar", :test => 1, :list => [1, 2, 3])
    assert_not_nil doc._id
    assert_not_nil doc._rev
    assert_not_nil doc.location
    assert_equal doc.foo, "bar"
    assert_equal doc.test, 1
    assert_equal doc.list, [1, 2, 3]
  end

  should "create a document and use callbacks" do
    doc = ExampleDocument.new
    doc.a = "b"
    doc.foo = "bar"
    assert_nil doc.something
    _id = doc.save
    assert_not_nil doc.something
    
    doc = ExampleDocument.find(_id)
    assert_equal doc._id, _id
    assert_equal doc.a, "b"
    assert_equal doc.something, "other"
  end

  should "find a document by id" do
    doc = ExampleDocument.create(:foo => "bar", :test => 1, :list => [1, 2, 3])
    assert_not_nil doc._id
    doc2 = ExampleDocument.find(doc._id)
    assert_equal doc._id, doc2._id
  end

  should "update a document" do
    doc = ExampleDocument.create(:foo => "bar", :test => 1, :list => [1, 2, 3])
    doc2 = ExampleDocument.find(doc._id)

    assert_not_nil doc._id
    doc.foo = "bar2"
    _rev_before = doc._rev
    _rev = doc.save
    assert _rev != _rev_before
    assert_equal doc.foo, 'bar2'

    assert_not_nil doc2
    assert doc2.changed?
  end

  should "destroy a document" do
    doc = ExampleDocument.create(:foo => "bar", :test => 1, :list => [1, 2, 3])
    assert_not_nil doc._id
    _id = doc._id
    assert doc.destroy
    doc2 = ExampleDocument.find(_id)
    assert_nil doc2
  end

  should "get all document handles" do
    doc = ExampleDocument.create(:foo => "bar", :test => 1, :list => [1, 2, 3])
    all_handles = ExampleDocument.keys
    assert_not_nil all_handles
    assert all_handles.include?(doc.location)
    assert doc.destroy
  end
end

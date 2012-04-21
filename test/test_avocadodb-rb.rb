require 'helper'

class ExampleDocument < AvocadoDb::Base
  collection :examples
end

# Example with predefined attributes
class AnotherExampleDocument < AvocadoDb::Base
  collection :more_examples
  attr_accessor :foo, :bar

  def to_json
    {'foo' => self.foo, 'bar' => self.bar}.to_json
  end
end

class TestAvocadodbRb < Test::Unit::TestCase
  should "create a new document" do
    doc = ExampleDocument.new
    doc.foo = "bar"
    doc.test = 1
    doc.list = [1, 2, 3]
    
    assert_nil doc._id
    assert_nil doc._rev
    
    _id = doc.save
    assert_not_nil _id
    assert_not_nil doc._id
    assert_not_nil doc._rev
    
    doc = ExampleDocument.find(_id)
    assert_equal doc._id, _id
    assert_equal doc.foo, "bar"
    assert_equal doc.test, 1
    assert_equal doc.list, [1, 2, 3]
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

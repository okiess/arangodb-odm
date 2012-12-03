require 'helper'

class TestArangoDbQueries < Test::Unit::TestCase
  should "get all documents" do
    example_documents = ExampleDocument.skip(1).limit(2).all
    assert_not_nil example_documents
    assert example_documents.is_a?(ArangoDb::Queries::QueryResult)
    assert example_documents.size > 0
    assert_equal example_documents.size, 2
  end

  should "get all documents by example" do
    example_documents = ExampleDocument.where(:foo => 'bar').where("test" => 1).where("list" => [1, 2, 3]).limit(10).all
    assert_not_nil example_documents
    assert example_documents.size > 0

    example_documents = ExampleDocument.where(:something => 'not existant').all
    assert_not_nil example_documents
    assert_equal example_documents.size, 0
  end

  should "get first document by example" do
    example_document = ExampleDocument.where('foo' => 'bar').first
    assert_not_nil example_document
    assert_not_nil example_document._id
    assert_not_nil example_document._rev
    assert_equal example_document.foo, 'bar'
    
    example_document = ExampleDocument.where(:something => 'not existant').first
    assert_nil example_document
  end
end

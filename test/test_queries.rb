require 'helper'

class TestArangoDbQueries < Test::Unit::TestCase
  should "get all documents" do
    example_documents = ExampleDocument.all
    assert_not_nil example_documents
    assert example_documents.is_a?(ArangoDb::Queries::QueryResult)
    # TODO
  end
end

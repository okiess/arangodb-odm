require 'helper'

class TestArangoDbIndices < Test::Unit::TestCase
  should "create skiplist" do
    assert ExampleDocument.ensure_indices
  end
end

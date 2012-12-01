# Example with predefined attributes
class AnotherExampleDocument < ArangoDb::Base
  collection :more_examples
  db_attrs :foo, :bar
  
  before_save :change_something
  after_save :change_something_else
  
  def change_something
    self.foo = 'bar2'
  end
  
  def change_something_else; end
end

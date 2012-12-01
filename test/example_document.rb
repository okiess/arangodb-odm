class ExampleDocument < ArangoDb::Base
  collection :examples
  
  before_create :add_something
  after_create :do_something_else
  
  before_destroy :method1
  after_destroy :method2

  def validate
    not self.foo.nil?
  end
  
  def add_something
    self.something = "other"
  end
  
  def do_something_else; end
  
  def method1
    # puts self._id
  end
  
  def method2
    # puts self._id
  end
end

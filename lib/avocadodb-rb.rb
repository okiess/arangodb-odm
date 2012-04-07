require "rubygems"
require "httparty"
require "json"

module AvocadoDb
  class Transport
    include HTTParty
    base_uri 'http://localhost:8529'
  end
end

module AvocadoDb
  class DocumentProxy
    attr_accessor :collection, :collection_id, :location, :_id, :_rev
    attr_reader :attributes

    def initialize(collection)
      @attributes = {}; self.collection = collection
    end

    def is_new?; self._id.nil?; end
  end
end

module AvocadoDbProperties
  def self.included(klass)  
    klass.extend ClassMethods  
  end  

  module ClassMethods  
    def collection(value)
      (class << self; self; end).send(:define_method, 'collection') do
        value
      end
    end
    
    def transport(value)
      (class << self; self; end).send(:define_method, 'transport') do
        value
      end
    end
    
    def target(value)
      (class << self; self; end).send(:define_method, 'target') do
        value
      end
    end
  end
end

# Base class for AvocadoDB documents.
#
# Example:
# class ExampleDocument < AvocadoDb::Base
#  collection 'examples'
# end
#
# doc = ExampleDocument.new
# doc.foo = "bar"
# _id = doc.save
#
# doc.foo = "bar2"
# doc.save
#
# doc.destroy
# 
# doc = ExampleDocument.find(_id)
#
module AvocadoDb
  class Base
    include AvocadoDbProperties
    transport AvocadoDb::Transport
    target AvocadoDb::DocumentProxy
    attr_reader :target

    def initialize
      @transport = self.class.transport
      @target = self.class.target.new(self.class.collection)
    end

    def self.find(document_handle)
      raise "missing document handle" if document_handle.nil?
      res = transport.get("/document/#{document_handle}")
      if res.code == 200
        document = self.new
        res.parsed_response.each {|k, v| document.send("#{k}=".to_sym, v) unless ['_id', '_rev'].include?(k)}
        document.target._id = res.parsed_response['_id']
        document.target._rev = res.parsed_response['_rev']
        document.target.location = "/document/#{document.target._id}"
        document
      else
        nil
      end
    end

    def save
      if @target.is_new?
        res = @transport.post("/document/?collection=#{@target.collection}&createCollection=true", :body => @target.attributes.to_json)
        if res.code == 201 || res.code == 202
          @target.location = res.headers["location"]
          @target._id = res.parsed_response["_id"]
          @target._rev = res.headers["etag"]
          return @target._id
        end
      else
        res = @transport.put(@target.location, :body => @target.attributes.to_json)    
        return (@target._rev = res.parsed_response['_rev'])
      end
      nil
    end

    def destroy
      unless is_new?
        res = @transport.delete(self.location)
        if res.code == 200
          @target.location = nil
          @target._id = nil
          @target._rev = nil
        end
      end
    end
    
    protected
    def method_missing(method, *args, &block)
      method = method.to_s
      if method[-1, 1] == '='
        @target.attributes[method.gsub('=', '')] = args.first unless ['_id=', '_rev='].include?(method)
      else
        val = @target.attributes[method]
        val = @target.send(method.to_sym) unless val
        val
      end
    end
  end
end

class ExampleDocument < AvocadoDb::Base
  collection 'examples'
end

require "rubygems"
require "httparty"
require "json"

module AvocadoDb
  class Base
    include HTTParty
    base_uri 'http://localhost:8529'
    
    def initialize(collection)
      @attributes = {}; @collection = collection; @is_new = true
    end
    
    def collection=(value); @collection = value; end
    def collection; @collection; end
    def attributes; @attributes; end
    def location; @location; end
    def id; @_id; end
    def version; @_etag; end

    def all
      # TODO
    end
    def self.find(collection, id)
      document = self.new(collection)
      document.find(id)
      document
    end
    def find(id)
      raise "missing id" if id.nil?
      res = Base.get("/_document/#{id}")
      @attributes.clear
      res.parsed_response.each {|k, v| self.send("#{k}=".to_sym, v) unless k == "_id" }
      @_id = res.parsed_response['_id']
      @_etag = @_id.split(":").last
      @is_new = false
      @attributes
    end
    def reload; self.find(self.id); end

    def is_new?; @is_new; end
    def save
      if is_new?
        res = Base.post("/_document/#{self.collection}", :body => @attributes.to_json)
        # puts res.inspect
        if res.code == 201
          @location = res.headers["location"]
          @_id = @location.split("/").last
          @_etag = @_id.split(":").last
          @is_new = false
          return @_id
        end
      else
        res = Base.put("/_document/#{self.id}", :body => @attributes.to_json)    
        @_etag = res.headers['etag']
      end
    end

    def destroy
      unless is_new?
        Base.delete("/_document/#{self.id}")
        @is_new = true; @attributes.clear; @_id = nil; @_etag = nil; @location = nil
      end
    end

    private
    def method_missing(method, *args, &block)
      if method.to_s[-1, 1] == '='
        @attributes[method.to_s.gsub('=', '')] = args.first
      else
        @attributes[method.to_s]
      end
    end
  end
end
